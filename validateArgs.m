function options = validateArgs(options, varargin)

  if mathlib.iseven(length(varargin))
    for ii = 1:2:length(varargin)-1
      temp = varargin{ii};
      if ischar(temp)
        if ~any(find(strcmp(temp,fieldnames(options))))
          disp(['Unknown option: ' temp])
          disp('The allowed options are:')
          disp(fieldnames(options))
          error('UNKNOWN OPTION')
        else
          options.(temp) = varargin{ii+1};
        end
      end
    end
  else
    error('Inputs need to be name value pairs')
  end

end % function
