clc
clear
close all;

%% Import data

sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).linear.time;
acceleration = sessionData.(sessionData.deviceNames{1}).linear.vector * 9.81; % convert to m/s/s

numberOfSamples = length(time);

% filter noise in acceleration data

function updatedVector = filterNoise(vector, lowerBound, upperBound)
  updatedVector = vector;
  % if vector is in between the lower and upper bounds, it is considered as noise
  if (vector > lowerBound && vector < upperBound)
    updatedVector = 0;
  endif
endfunction

thresholds = [-0.5 -0.5 -0.5; 0.5 0.5 0.5]; % noise filter threshold for [x, y, z], lower and upper bounds
for index = 1: numberOfSamples
  for vectorIndex = 1: 3
    acceleration(index, vectorIndex) = filterNoise(acceleration(index, vectorIndex), thresholds(1, vectorIndex), thresholds(2, vectorIndex));
  end
end

% integrate for velocity
velocity = cumtrapz(time, acceleration);

% integrate for displacement
displacement = cumtrapz(time, velocity);

% plot data
plotData(time, acceleration, velocity, displacement);