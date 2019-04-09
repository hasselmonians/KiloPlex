classdef KiloPlex

properties

  options
  % a struct that contains all the options required
  % to run KiloSort2

end % properties

methods

  function self = KiloPlex()

    %% set up the options property using defaults

    %% File paths

    options.chanMap   = '/projectnb/hasselmogrp/hoyland/kiloplex/channel_map.m';
    options.fproc     = []; % will be determined by batch function arguments
    options.fbinary   = []; % will be determined by batch function arguments

    %% General settings

    % sample rate
    options.fs = 30000;

    % frequency for high pass filtering (150)
    options.fshigh = 150;

    % minimum firing rate on a "good" channel (0 to skip)
    options.minfr_goodchannels = 0.1;

    % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
    options.Th = [10 4];

    % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot)
    options.lam = 10;

    % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
    options.AUCsplit = 0.9;

    % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
    options.minFR = 1/50;

    % number of samples to average over (annealed from first to second value)
    options.momentum = [20 400];

    % spatial constant in um for computing residual variance of spike
    options.sigmaMask = 30;

    % threshold crossings for pre-clustering (in PCA projection space)
    options.ThPre = 8;

    % time range to sort
    options.trange = [0 Inf];

    % total number of channels in recording
    options.NchanTOT = 96;

    %% Experimental settings
    % options for determining PCs
    options.spkTh           = -6;      % spike threshold in standard deviations (-6)
    options.reorder         = 1;       % whether to reorder batches for drift correction.
    options.nskip           = 25;  % how many batches to skip for determining spike PCs

    options.GPU                 = 1; % has to be 1, no CPU version yet, sorry
    % options.Nfilt               = 1024; % max number of clusters
    options.nfilt_factor        = 4; % max number of clusters per good channel (even temporary ones)
    options.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
    options.NT                  = 64*1024+ options.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory).
    options.whiteningRange      = 32; % number of channels to use for whitening each channel
    options.nSkipCov            = 25; % compute whitening matrix from every N-th batch
    options.scaleproc           = 200;   % int16 scaling of whitened data
    options.nPCs                = 3; % how many PCs to project the spikes into
    options.useRAM              = 0; % not yet available


    self.options    = options;

  end % constructor

  function publish(self, location)
    % saves the options as a .mat file to be loaded before using kilosort
    % location is a filepath to the output
    options = self.options;
    if ~exist(location, 'file')
      mkdir(location);
    end
    save(location, 'options');
  end

end % methods

methods (Static)

  [data, fid] = readPLX(filename, varargin)
  [headers, fid, easyread] = readPLXHeaders(filename, fullread)
  batchFunction(index, batchname, location, outfile, test)
  plx = plx2mat(filename)

end % static methods

end % classdef
