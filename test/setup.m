% setup script to create the required RatCatcher object and batch

% generate the RatCatcher object
r = RatCatcher;
r.expID           = 'test';
r.remotepath      = '/projectnb/hasselmogrp/hoyland/KiloPlex/cluster';
r.localpath       = '/mnt/hasselmogrp/hoyland/KiloPlex/cluster';
r.protocol        = 'KiloPlex';
r.filenames       = {'/projectnb/hasselmogrp/hoyland/data/winny/rawDataSample.bin'};
r.batchscriptpath = which('KiloPlex-batch-script.sh');
r.project         = 'hasselmogrp';
r.verbose         = true;

r = r.validate();

% copy the channel map file
% downloaded (and renamed) from data.cortexlab.net
copyfile(which('channel_map.mat'), fullfile(r.localpath, ['channel_map-' r.batchname '.mat']));
options.chanMap = fullfile(r.localpath, ['channel_map-' r.batchname '.mat']);

% create the options file
getOptions;
r.lamplight(options);

% perform the batching process
r                 = r.batchify();
