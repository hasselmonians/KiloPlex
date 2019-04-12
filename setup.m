% setup script to create the required RatCatcher object and batch

r = RatCatcher;
r.expID           = 'test';
r.remotepath      = '/projectnb/hasselmogrp/hoyland/KiloPlex/cluster';
r.localpath       = '/mnt/hasselmogrp/hoyland/KiloPlex/cluster';
r.protocol        = 'KiloPlex';
r.filenames       = RatCatcher.getFileNames('data/winny/raw', '**/*.mat', '/mnt/hasselmogrp/hoyland/');
r.batchscriptpath = which('KiloPlex-batch-script.sh');
r.project         = 'hasselmogrp';
r.verbose         = true;

r.batchify();
