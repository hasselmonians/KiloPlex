function channel_map = createChannelMap(self, filepath)
  % creates a channel map file (.mat) in `location`
  % automatically determines the correct values
  % based on Kilosort2/configFiles/createChannelMap.m
  % assuming that you're using a set of tetrodes (not a linear probe)


  Nchannels = self.options.NchanTOT;
  connected = true(Nchannels,1);
  chanMap 	= 1:Nchannels;
  chanMap0ind = chanMap - 1;
  xcoords 	= corelib.vectorise(repmat([1 2 3 4]', 1, Nchannels/4));
  ycoords 	= corelib.vectorise(repmat(1:Nchannels/4, 4, 1));
  kcoords 	= ones(Nchannels, 1);
  fs 				= self.options.fs;
  save(filepath, 'chanMap', 'chanMap0ind', 'xcoords', 'ycoords', 'kcoords', 'fs');

end % function
