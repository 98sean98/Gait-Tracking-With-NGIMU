clc
clear
close all;

% import data
sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).matrix.time;
rotMRaw = sessionData.(sessionData.deviceNames{1}).matrix.matrix;

frequency = 400; % Hz
assumedConstantVelocity = 0.119; % m/s
shouldCorrectBiasRotM = false;

sampleSize = length(time);

rotM = zeros(3, 3, sampleSize);

for index = 1 : sampleSize
  rotM(:, :, index) = rotMRaw(:, :, index)';
end

% remove first and last few seconds of data
timeCutoff = [163 40]; % cut off first few and last few seconds of data
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
end

for rowIndex = rowIndexCutOff(2): sampleSize
  time(end) = [];
  rotM(:, :, end) = [];
end

sampleSize = length(time)
for rowIndex = 1 : sampleSize
  time(rowIndex) = time(rowIndex) - timeCutoff(1);
end

t = 1 / frequency;

distance = zeros(sampleSize);

for index = 1 : sampleSize
  v1 = assumedConstantVelocity;
  v2 = v1;

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

  aggregateRotM = R;
  if (shouldCorrectBiasRotM)
    aggregateRotM = biasCorrectionRotM * R;
  endif

  travelVector = aggregateRotM * [d 0 0]';

  p2 = p1 + travelVector;

  if (index < sampleSize)
    position(index + 1, :) = p2';
  endif
end

% flip position y-axis along y = 0
position(:, 2) = - position(:, 2);

% plot data
plotData(time, position);
