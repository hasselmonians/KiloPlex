function data = convert(data, verbose)
  % forces a matrix to contain data of type int16
  % if the matrix is not int16, normalizes by the minimum value
  % to force all values to be integers

  % this is necessary for a data matrix to be passed to kilosort

  if nargin < 2
    verbose = false
  end

  w = whos('data');

  if w.class == 'int16'
    if verbose
      disp('[INFO] data are already of class int16')
    end
  else
    data = data ./ min(abs(data(:)));
    if verbose
      disp('[INFO] scaling data by min(data(:))')
    end
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

end % function
