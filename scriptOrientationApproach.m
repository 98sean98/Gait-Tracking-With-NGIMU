clc
clear
close all;

% import data
sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).matrix.time;
rotMRaw = sessionData.(sessionData.deviceNames{1}).matrix.matrix;
acceleration = sessionData.(sessionData.deviceNames{1}).linear.vector * 9.81;

frequency = 400; % Hz
shouldUseConstantVelocity = true;
assumedConstantVelocity = 1.5; % m/s

sampleSize = length(time);

rotM = zeros(3, 3, sampleSize);

for index = 1 : sampleSize
  rotM(:, :, index) = rotMRaw(:, :, index)';
end

% filter acceleration noise
function [updatedVector] = filterNoise(vector, lowerBound, upperBound)
  updatedVector = vector;
  % if vector is in between the lower and upper bounds, it is considered as noise
  if (vector > lowerBound && vector < upperBound)
    updatedVector = 0;
  endif
endfunction

thresholds = [-0.1 -0.1 -1; 0.1 0.1 1]; % noise filter threshold for [x, y, z], lower and upper bounds
for index = 1: length(acceleration)
  for vectorIndex = 1: 3
    [acceleration(index, vectorIndex)] = filterNoise(acceleration(index, vectorIndex), thresholds(1, vectorIndex), thresholds(2, vectorIndex));
  end
end

% use complementary filter to fuse accelerometer and gyroscope data to obtain rotation matrices

% remove first and last few seconds of data
timeCutoff = [3 3]; % cut off first few and last few seconds of data
rowIndexCutOff = [0 0];

for rowIndex = 1 : sampleSize
  if (time(rowIndex) < timeCutoff(1))
    rowIndexCutOff(1) = rowIndexCutOff(1) + 1;
  elseif (time(rowIndex) > (time(end) - timeCutoff(2)))
    rowIndexCutOff(2) = rowIndex;
    break;
  endif
end

for rowIndex = 1: rowIndexCutOff(1)
  time(1) = [];
  rotM(:, :, 1) = [];
  acceleration(1, :) = [];
end

for rowIndex = rowIndexCutOff(2): sampleSize
  time(end) = [];
  rotM(:, :, end) = [];
  acceleration(end, :) = [];
end

sampleSize = length(time);
for rowIndex = 1 : sampleSize
  time(rowIndex) = time(rowIndex) - timeCutoff(1);
end

% calculate discrete travel distance from linear acceleration
if (length(acceleration) < sampleSize)
  acceleration = [acceleration(:, 1); zeros(sampleSize - length(acceleration), 1)];
else
  acceleration = acceleration(1 : sampleSize, 1);
endif
velocity = zeros(sampleSize); 
t = 1 / frequency;

for index = 1 : sampleSize
  v1 = velocity(index);
  a = acceleration(index);
  v2 = v1 + a * t;
  
  if (index < sampleSize)
    velocity(index + 1) = v2;
  endif
end

% constant velocity at 1m/s
if (shouldUseConstantVelocity)
  velocity = zeros(sampleSize) + assumedConstantVelocity;
endif

distance = zeros(sampleSize);

for index = 1 : sampleSize
  v1 = velocity(index);
  
  if (index == sampleSize)
    v2 = 0;
  else
    v2 = velocity(index + 1);
  endif
  
  d = 0.5 * (v1 + v2) * t;
  
  if (d < 0)
    distance(index) = 0;
  else
    distance(index) = d;
  endif
end

% obtain rotation matrix for bias correction
stationaryRowIndexCutOff = 400;
stationaryRotM = rotM(:, :, 1 : stationaryRowIndexCutOff);
meanStationaryRotM = mean(stationaryRotM, 3)
biasCorrectionRotM = inverse(meanStationaryRotM)

% use rotation matrices to propogate position data
position = zeros(sampleSize, 3);

for index = 1 : sampleSize
  p1 = position(index, :)';
  d = distance(index);
  
  R = rotM(:, :, index);
  
  aggregateRotM = biasCorrectionRotM * R;
  
  travelVector = aggregateRotM * [d 0 0]';
  
  p2 = p1 + travelVector;
  
  if (index < sampleSize)
    position(index + 1, :) = p2';
  endif
end

% flip position y-axis along y = 0
position(:, 2) = - position(:, 2);

% rotate position data from body frame to earth frame

% plot data
accelerationData = horzcat(acceleration, zeros(sampleSize, 2));
velocityData = horzcat(velocity, zeros(sampleSize, 2));
plotData(time, accelerationData, velocityData, position);