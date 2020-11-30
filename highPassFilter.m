function filteredData = highPassFilter(sampleFrequency, data)
  order = 1;
  filtCutOff = 0.1;
  [b, a] = butter(order, (2 * filtCutOff)/(sampleFrequency), 'high');
  filteredData = filtfilt(b, a, data);
endfunction
