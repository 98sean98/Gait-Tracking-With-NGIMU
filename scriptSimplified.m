clc
clear
close all;

%% Import data

sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).earth.time;
acceleration = sessionData.(sessionData.deviceNames{1}).earth.vector * 9.81; % convert to m/s/s

numberOfSamples = length(time);

% remove first and last few seconds of data
timeCutoff = [27 13]; % cut off first 3 and last 3 seconds of data
rowIndexCutOff = [0 0];

for rowIndex = 1: numberOfSamples
  if (time(rowIndex) < timeCutoff(1))
    rowIndexCutOff(1) = rowIndexCutOff(1) + 1;
  elseif (time(rowIndex) > (time(end) - timeCutoff(2)))
    rowIndexCutOff(2) = rowIndex;
    break;
  endif
end

for rowIndex = 1: rowIndexCutOff(1)
  time(1) = [];
  acceleration(1, :) = [];
end

for rowIndex = rowIndexCutOff(2): numberOfSamples
  time(end) = [];
  acceleration(end, :) = [];
end

updatedNumberOfSamples = length(time);
for rowIndex = 1 : updatedNumberOfSamples
  time(rowIndex) = time(rowIndex) - timeCutoff(1);
end

% filter noise in acceleration data

function updatedVector = filterNoise(vector, lowerBound, upperBound)
  updatedVector = vector;
  % if vector is in between the lower and upper bounds, it is considered as noise
  if (vector > lowerBound && vector < upperBound)
    updatedVector = 0;
  endif
endfunction

thresholds = [0 -1 -1 ; 0 1 1.2]; % noise filter threshold for [x, y, z], lower and upper bounds
for index = 1: updatedNumberOfSamples
  for vectorIndex = 1: 3
    acceleration(index, vectorIndex) = filterNoise(acceleration(index, vectorIndex), thresholds(1, vectorIndex), thresholds(2, vectorIndex));
  end
end

% numerically integrate for velocity
velocity = cumtrapz(time, acceleration);

% numerically integrate for displacement
displacement = cumtrapz(time, velocity);

% plot data
plotData(time, acceleration, velocity, displacement);