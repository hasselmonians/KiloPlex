function batchFunction(index, location, batchname, outfile, test)

  % runs kilosort

  if ~test
    addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/KiloPlex/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/KiloSort2/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools/src/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
    import CMBHOME.*
  end

  %% Set up options determined at runtime

  % this file is automatically generated during lamplighting
  load(fullfile(location, batchname, 'options.mat'));

  % generate an 'fproc' file
  options.fproc   = fullfile(location, batchname, ['temp_wh', num2str(index), '.dat']);

  % location the data
  options.fbinary = RatCatcher.read(index, location, batchname);

  %% Pre-process the data

  results   = clusterSingleBatches(preprocessDataSub(options));

  %% Main tracking and tempalte matching algorithm

  results   = learnAndSolve8b(results);
  results   = find_merges(results, 1);
  results   = splitAllClusters(results, 1);
  results   = splitAllClusters(results, 0);
  results   = set_cutoff(results);

  %% Post-process the data

  results.cProj = [];
  results.cProjPC = [];

  % save the data

  outfile = [outfile(1:end-2), '.mat'];
  save(outfile, 'results');

end % function
