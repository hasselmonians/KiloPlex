function batchFunction(index, location, batchname, outfile, test)

  % runs kilosort

  if ~test
    addpath(genpath('/projectnb/hasselmogrp/hoyland/MLE-time-course/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/KiloPlex/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/KiloSort2/'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/srinivas.gs_mtools'))
    addpath(genpath('/projectnb/hasselmogrp/hoyland/CMBHOME/'))
    import CMBHOME.*
  end

  %% Compile
  mex -setup C++
  run(which('mexGPUall'))

  %% Set up options determined at runtime

  % this file is automatically generated during lamplighting
  load(fullfile(location, ['options-' batchname '.mat']));

  % generate an 'fproc' file location
  options.fproc = fullfile(location, batchname, ['temp_wh.dat']);

  % load the entire filename file
  % this is slow, but MATLAB has clunky textread options
  filename = filelib.read(fullfile(location, ['filenames-', batchname, '.txt']));
  % acquire only the character vector corresponding to the indexed filename
  options.fbinary = filename{index};

  %% Pre-process the data

  % preprocess to produce temp_wh.dat (saved at options.fproc)
  results   = preprocessDataSub(options);

  % time-reordering as a function of drift
  results   = clusterSingleBatches(preprocessDataSub(options));

  %% Main tracking and template matching algorithm

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

  %% Cleanup

  delete(options.fproc);

end % function
