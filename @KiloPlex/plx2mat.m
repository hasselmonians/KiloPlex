function plx = plx2mat(filename)

  if ~exist('readPLXFileC.mexa64', 'file')
    disp('[INFO] building ''readPLXFile.c''')
    build_readPLXFileC()
  end

  plx = readPLXFileC(filename, 'all');

end % function
