function data = convert(data, filepath, verbose)
  % forces a matrix to contain data of type int16
  % if the matrix is not int16, normalizes by the minimum value
  % to force all values to be integers
  %
  % Arguments:
  %   data: a matrix of some numerical type (usually double)
  %     the matrix should contain electrophysiology data
  %     as time-series from electrodes
  %   filepath: the full filepath (.bin file) where the data should be saved
  %     if this is empty, no data are saved (kept in workspace)
  %   verbose: a flag to toggle debugging display statements
  %
  %   myConvertedData = KiloPlex.convert(myData, 'path2file/filename.bin', true)

  % this is necessary for a data matrix to be passed to kilosort

  if nargin < 2
    filepath = [];
  end

  if nargin < 3
    verbose = false
  end

  w = whos('data');

  if w.class == 'int16'
    if verbose
      disp('[INFO] data are already of class int16')
    end
  else
    data = data ./ min(nonzeros(abs(data(:))));
    if verbose
      disp('[INFO] scaling data by nonzero absolute minimum')
    end
    data = int16(data);
    if verbose
      disp('[INFO] converting to int16')
    end
  end

  if size(data, 1) > size(data, 2)
    data = data';
    if verbose
      disp('[INFO] second dimension should be time...transposing data')
    end
  end

  if ~isempty(filepath)
    fileID = fopen(filepath, 'w');
    fwrite(fileID, data, 'int16');
    fclose(fileID);
    disp('[INFO] saved data')
  end

end % function
