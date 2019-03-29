function [data, fid] = readPLX(filename, varargin)
% readPLXFile - Read data from PLX file.
%
% [data, fid] = readPLXFile(filename, varargin)
%
% readPLXFile will read all (or a subset) of the data from a PLX file and
% return a structure with fields containing the requested data.
%
% Input:
%   filename - Filename of a PLX file. A valid file-ID can be provided
%              instead of a filename. In this case, the file-ID will not be
%              closed after reading.
%   varargin - One (or more) of the arguments listed below. Arguments are
%              parsed in order, with later arguments overriding earlier
%              arguments. e.g. try not to repeat variables.  YOU MUST ADD
%              SOME OF THESE IF YOU WANT TO PULL DATA AND NOT JUST CHECK IT
%
% See also writePLXFile, checkPLXData, plx_info, plx_information.
%
% Arguments:
% 'headers'      - Retrieve *only* headers (with 'fullread')
%                  (implies 'nospikes','noevents','nocontinuous')
% '[no]spikes'   - Retreive (or not) spike timestamps (default = 'spikes')
%                  'nospikes' implies 'nowaves'
% '[no]waves     - Retreive (or not) spike waveforms (default = 'nowaves')
%                  'waves' implies 'spikes'
% '[no]events'   - Retreive (or not) event data (default = 'events')
% '[no]continuous' - Retreive (or not) continuous data (default = 'no')
%
% Selecting channels:
%   'spikes','waves','events', and/or 'continuous' can be followed by a
%   cell array, which is then parsed to determine which channels to
%   retrieve. String entries are interpretted as channel names, while
%   numerical entries are treated as channel numbers. Specifying 'no' is
%   equivalent to providing an empty cell array. If the cell array is
%   missing, then all channels are retreived.

% Typical usage
% [data,fid]=readPLXFile('','spikes',[1:5],'nowaves')
% this will pull only spike channels 1:5, no waves, and only valid events
% and lfps
%
% AUTHOR: Benjamin Kraus (bkraus@bu.edu, ben@benkraus.com)
% Copyright (c) 2011, Benjamin Kraus
% $Id$

% debug actually goes through each block to see whether the headers
% actually match the data structure
if any(cellfun(@(x) strcmp(x,'DEBUG'), varargin))
    DEBUG=1;
else
    DEBUG=0;
end

% if no file given, get one
if (nargin == 0 || isempty(filename))
    FilterSpec = {'*.plx', 'Plexon PLX File (*.plx)';
                  '*', 'All Files'};
    [fname, pathname] = uigetfile(FilterSpec, 'Select a Plexon PLX file');
    if(fname == 0); data = struct(); return; end
    filename = strcat(pathname, fname);
end

    % If the filename input is not a character string, check to see if it
    % is a valid file ID instead. We can do this by calling 'frewind'. If
    % 'frewind' succeeds, then we know we have a valid file ID.
if(~ischar(filename))
    fid = filename;
    frewind(fid);
else
    fid = fopen(filename, 'r');
    if(fid ~= -1 && nargout < 2); c = onCleanup(@()fclose(fid)); end
end

% if we cant open the file, throw error
if(fid == -1); error('readPLXData:FileError','Error opening file'); end

% Lets get the header data, so we can use it to parse the optional inputs.
% this will double check the data if debug is true
[headers,~,easyread] = Kiloplex.readPLXHeaders(fid, logical(DEBUG));

% if we wont be able to parse our dataset, return
if ~easyread, return; end


% now start setting up the headers to fill in
data.headers = headers;

% first get channels
if(numel(headers.chans)>0)
    channames = {headers.chans.name}';
    channums = vertcat(headers.chans.channel);
else
    channames = {};
    channums = [];
end
% cmap is the channel map
cmap = nan(max(channums),1);
cmap(channums) = 1:numel(channums);

% now get events
if(numel(headers.evchans)>0)
    evnames = {headers.evchans.name}';
    evnums = vertcat(headers.evchans.num);
else
    evnames = {};
    evnums = [];
end
evmap = nan(max(evnums),1);
evmap(evnums) = 1:numel(evnums);

% now get slow channels (conts i think)
if(numel(headers.slowchans)>0)
    slownames = {headers.slowchans.name}';
    slownums = vertcat(headers.slowchans.channel);
else
    slownames = {};
    slownums = [];
end
slowmap = nan(max(slownums)+1,1);
slowmap(slownums+1) = 1:numel(slownums);

% get valid everything unless we explicitly say no to any of these
getspikes = ~isnan(cmap);
getwaves = ~isnan(cmap);
% but not waves
getwaves = false(size(cmap));
getevents = ~isnan(evmap);
getslow = ~isnan(slowmap);

args = varargin;
while ~isempty(args)
    switch args{1}
        case 'headers'
            getspikes(:) = false;
            getwaves(:) = false;
            getevents(:) = false;
            getslow(:) = false;
        case 'spikes'
            if(numel(args)>1 && iscell(args{2}))
                getspikes = parsecell(args{2}, channames, channums, cmap);
                args = args(2:end);
            else getspikes(:) = ~isnan(cmap);
            end
        case 'nospikes'
            getspikes(:) = false;
            getwaves(:) = false;
        case 'waves'
            if(numel(args)>1 && iscell(args{2}))
                getwaves = parsecell(args{2}, channames, channums, cmap);
                args = args(2:end);
            else getwaves(:) = ~isnan(cmap);
            end
            getspikes = getspikes || getwaves;
        case 'nowaves'
            getwaves(:) = false;
        case 'events'
            if(numel(args)>1 && iscell(args{2}))
                getevents = parsecell(args{2}, evnames, evnums, evmap);
                args = args(2:end);
            else getevents(:) = ~isnan(evmap);
            end
        case 'noevents'
            getevents(:) = false;
        case 'continuous'
            if(numel(args)>1 && iscell(args{2}))
                getslow = parsecell(args{2}, slownames, slownums, slowmap);
                args = args(2:end);
            else getslow(:) = ~isnan(slowmap);
            end
        case 'nocontinuous'
            getslow(:) = false;
    end
    % delete the query you just did and move forward
    args = args(2:end);
end

getspikes = getspikes | getwaves;

if(DEBUG); fprintf('Initializing data structures. \n'); end

% Initialize the data structure and output variables:
if(any(getspikes))
    for ii = 1:headers.numDSPChannels
        channel = headers.chans(ii,1).channel;
        data.spikes(ii,1).name = headers.chans(ii,1).name;
        data.spikes(ii,1).channel = channel;
        if(getspikes(channel))
            data.spikes(ii,1).ts = zeros(sum(headers.tscounts(:,channel)),2);
        else
        end
        % and wave
        if(getspikes(channel))
            data.spikes(ii,1).wave = zeros([sum(headers.tscounts(:,channel))...
                ,headers.numPointsWave],'int16');
        else data.spikes(ii,1).wave = [];
        end
    end
end

if(any(getevents))
    for ii = 1:headers.numEventChannels
        num = headers.evchans(ii,1).num;
        data.events(ii,1).name = headers.evchans(ii,1).name;
        data.events(ii,1).num = num;
        if(getevents(num))
            data.events(ii,1).ts = zeros(headers.evcounts(num),2);
        else data.events(ii,1).ts = [];
        end
    end
end

if(any(getslow))
    for ii = 1:headers.numSlowChannels
        channel = headers.slowchans(ii,1).channel;
        data.continuous(ii,1).name = headers.slowchans(ii,1).name;
        data.continuous(ii,1).channel = channel;
        if(getslow(channel+1))
            data.continuous(ii,1).ts = zeros(headers.slowfrags(channel+1),2);
            data.continuous(ii,1).ad = zeros(headers.slowcounts(channel+1),1,'int16');
        else
            data.continuous(ii,1).ts = [];
            data.continuous(ii,1).ad = [];
        end
    end
end

% Initialize counters
spkcount = zeros(headers.numDSPChannels,1);
% events
evcount = zeros(headers.numEventChannels,1);
% number of fragments?
fragcount = zeros(headers.numSlowChannels,1);
% analog to digital signal
adcount = zeros(headers.numSlowChannels,1);

% Everything is ready, lets start reading the file.
fseek(fid,headers.datastart,'bof');

if(DEBUG); fprintf('Reading data.\n'); end
datablocks = 0;
% while youre still before the end of the file
while(~feof(fid))
    % read this datablock;
    type = fread(fid,1,'short');
    if(isempty(type)); break; end

    datablocks = datablocks + 1;

    % if debugging, lets plot our progress
    if(DEBUG && mod(datablocks,100000)==0); fprintf('Block: %.0f\n',datablocks); end

    %%%% get the header information before proceeding %%%%


    % max and mins of this dataset
    upperts = fread(fid,1,'ushort');
    lowerts = fread(fid,1,'uint32');

    % which channel is it
    chan = fread(fid,1,'short');

    % is it a unit? usually no
    unit = fread(fid,1,'short');
    % number of 'waves'
    nwaves = fread(fid,1,'short');
    % words per wave (datapoints)
    nwords = fread(fid,1,'short');

    ts = upperts*2^32+lowerts;

    try
        waves = fread(fid,[nwords nwaves],'*short');
    catch
        fprintf('The fuckup is in this block: %d \n', datablock);
    end

    %%%%%% if we want to pull this data, read through all of it %%%%%%%
    if(type == 1 && getspikes(chan))
        % spikes should be a single vector
        if size(waves,2)>1
            disp('fucked up dataset here');
        end
        spkcount(cmap(chan)) = spkcount(cmap(chan)) + 1;
        data.spikes(cmap(chan),1).ts(spkcount(cmap(chan)),:) = [ts unit];
        if(getwaves(chan))
            data.spikes(cmap(chan),1).wave(spkcount(cmap(chan)),1:nwords) = waves(1:nwords);
        end
    elseif(type == 4 && getevents(chan))
        % these come in as...
        evcount(evmap(chan)) = evcount(evmap(chan)) + 1;
        data.events(evmap(chan),1).ts(evcount(evmap(chan)),:) = [ts unit];
    elseif(type == 5 && getslow(chan+1))
        % right, so these fragments come in as a matrix of timestamps, and
        % they may or may not be ocntinuous from last dataset

        % Add in code here to automatically check if the fragment is
        % continuous from previous fragment and if so combine the two.
        fragcount(slowmap(chan+1)) = fragcount(slowmap(chan+1)) + 1;

        data.continuous(slowmap(chan+1),1).ts(fragcount(slowmap(chan+1)),:) = [ts nwaves*nwords];
        data.continuous(slowmap(chan+1),1).ad(adcount(slowmap(chan+1))+1:adcount(slowmap(chan+1))+nwaves*nwords) = waves(:);
        adcount(slowmap(chan+1)) = adcount(slowmap(chan+1)) + nwaves*nwords;
    end
end

end

% this function is for parsing the inputs, ben wrote his own input parser
% basically.
function getlist = parsecell(arg, names, nums, map)
    % map matches channel number with the order they are stored in the
    % headers or the order they are stored in the output struct.
    % First column is the channel numbers, second column is sort order.
    offset = find(map==1)-nums(1);
    getlist = false(size(map));

    namelist = arg(cellfun(@ischar,arg));
    numlist = arg{cellfun(@isscalar,arg)};

    getlist(nums(ismember(names,namelist))+offset,1) = true;
    getlist(nums(ismember(nums, numlist))+offset,1) = true;
end
