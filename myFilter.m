% high pass filter is used to remove drift

function filteredData = myFilter(data, sampleFrequency, filterCutoff, filterType)
  order = 1;
  fn = sampleFrequency / 2; % nyquist frequency
  ws = filterCutoff / fn;

  [b, a] = butter(order, ws, filterType);
  filteredData = filtfilt(b, a, data);
endfunction
