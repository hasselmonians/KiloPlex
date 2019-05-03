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

% create the options file
getOptions;
r.lamplight(options);

% copy the channel map file
% downloaded (and renamed) from data.cortexlab.net
copyfile(which('chanMap.mat'), r.localpath);

% perform the batching process
r                 = r.batchify();
