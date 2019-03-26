function plx = plx2mat(filename)

  if ~exist('readPLXFileC.mexa64', 'file')
    disp('[INFO] building ''readPLXFile.c''')
  end

  plx = readPLXFileC(filename);

end % function
