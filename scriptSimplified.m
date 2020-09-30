clc
clear
close all;

%% Import data

sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).earth.time;
acceleration = sessionData.(sessionData.deviceNames{1}).earth.vector * 9.81; % convert to m/s/s

numberOfSamples = length(time);

% filter noise in acceleration data

function updatedVector = filterNoise(vector, threshold)
  updatedVector = vector;
  if (abs(vector) < threshold)
    updatedVector = 0;
  endif
endfunction

thresholds = [0.05 1 5]; % noise filter threshold for [x, y, z]
for index = 1: numberOfSamples
  for vectorIndex = 1: 3
    acceleration(index, vectorIndex) = filterNoise(acceleration(index, vectorIndex), thresholds(vectorIndex));
  end
end

% integrate for velocity
velocity = cumtrapz(time, acceleration);

% integrate for displacement
displacement = cumtrapz(time, velocity);

% plot data
plotData(time, acceleration, velocity, displacement);