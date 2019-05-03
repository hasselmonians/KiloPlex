% options file for data from N. Steinmetz

options.verbose             = 1;
options.showfigures         = 1;

options.datatype            = 'dat';  % binary ('dat', 'bin') or 'openEphys'
options.root                = 'J:\Hopkins\20160722';
% options.fbinary             = fullfile(options.root, 'Hopkins_20160722_g0_t0.imec.ap_CAR.bin'); % will be created for 'openEphys'
% options.fproc               = fullfile(options.root, 'temp_wh.dat'); % residual from RAM of preprocessed data
options.fbinary             = [];
options.fproc               = [];

options.fs                  = 30000;        % sampling rate
options.NchanTOT            = 385;           % total number of channels
options.Nchan               = 374;           % number of active channels
options.Nfilt               = 960;           % number of filters to use (512, should be a multiple of 32)
options.nNeighPC            = 16; % visualization only (Phy): number of channnels to mask the PCs, leave empty to skip (12)
options.nNeigh              = 16; % visualization only (Phy): number of neighboring templates to retain projections of (16)

% options for channel whitening
options.whitening           = 'full'; % type of whitening (default 'full', for 'noSpikes' set options for spike detection below)
options.nSkipCov            = 1; % compute whitening matrix from every N-th batch
options.whiteningRange      = 32; % how many channels to whiten together (Inf for whole probe whitening, should be fine if Nchan<=32)

% define the channel map as a filename (string) or simply an array
options.chanMap             = fullfile(options.root, 'forPRBimecP3opt3.mat'); % make this file using createChannelMapFile.m
% options.chanMap = 1:options.Nchan; % treated as linear probe if a chanMap file

% other options for controlling the model and optimization
options.Nrank               = 3;    % matrix rank of spike template model (3)
options.nfullpasses         = 6;    % number of complete passes through data during optimization (6)
options.maxFR               = 20000;  % maximum number of spikes to extract per batch (20000)
options.fshigh              = 300;   % frequency for high pass filtering
options.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
options.scaleproc           = 200;   % int16 scaling of whitened data
options.NT                  = 32*1024+ options.ntbuff;% this is the batch size (try decreasing if out of memory)
% for GPU should be multiple of 32 + ntbuff

% these options can improve/deteriorate results.
% when multiple values are provided for an option, the first two are beginning and ending anneal values,
% the third is the value used in the final pass.
options.Th               = [4 10 10];    % threshold for detecting spikes on template-filtered data ([6 12 12])
options.lam              = [5 20 20];   % large means amplitudes are forced around the mean ([10 30 30])
options.nannealpasses    = 4;            % should be less than nfullpasses (4)
options.momentum         = 1./[20 400];  % start with high momentum and anneal (1./[20 1000])
options.shuffle_clusters = 1;            % allow merges and splits during optimization (1)
options.mergeT           = .1;           % upper threshold for merging (.1)
options.splitT           = .1;           % lower threshold for splitting (.1)

% options for initializing spikes from data
options.initialize      = 'no'; %'fromData' or 'no'
options.spkTh           = -6;      % spike threshold in standard deviations (4)
options.loc_range       = [3  1];  % ranges to detect peaks; plus/minus in time and channel ([3 1])
options.long_range      = [30  6]; % ranges to detect isolated peaks ([30 6])
options.maskMaxChannels = 5;       % how many channels to mask up/down ([5])
options.crit            = .65;     % upper criterion for discarding spike repeates (0.65)
options.nFiltMax        = 10000;   % maximum "unique" spikes to consider (10000)

% options for posthoc merges (under construction)
options.fracse  = 0.1; % binning step along discriminant axis for posthoc merges (in units of sd)
options.epu     = Inf;

options.ForceMaxRAMforDat   = 20e9; %0e9;  % maximum RAM the algorithm will try to use
options.GPU                 = true;
