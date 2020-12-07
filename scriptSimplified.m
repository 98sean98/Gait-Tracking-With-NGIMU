clc
clear
close all;

%% Import data

sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).linear.time;
acceleration = sessionData.(sessionData.deviceNames{1}).linear.vector * 9.81; % convert from g to m/s/s
sampleFrequency = 400;

% correct the orientation
acceleration(:, 2) = -1 * acceleration(:, 2);

numberOfSamples = length(time);

% % remove first and last few seconds of data
% timeCutoff = [0 0]; % cut off first few and last few seconds of data
% rowIndexCutOff = [0 0];
%
% for rowIndex = 1: numberOfSamples
%   if (time(rowIndex) < timeCutoff(1))
%     rowIndexCutOff(1) = rowIndexCutOff(1) + 1;
%   elseif (time(rowIndex) > (time(end) - timeCutoff(2)))
%     rowIndexCutOff(2) = rowIndex;
%     break;
%   endif
% end
%
% for rowIndex = 1: rowIndexCutOff(1)
%   time(1) = [];
%   acceleration(1, :) = [];
% end
%
% for rowIndex = rowIndexCutOff(2): numberOfSamples
%   time(end) = [];
%   acceleration(end, :) = [];
% end
%
% updatedNumberOfSamples = length(time);
% for rowIndex = 1 : updatedNumberOfSamples
%   time(rowIndex) = time(rowIndex) - timeCutoff(1);
% end

% filter noise, and obtain is stationary matrix
accleration = myFilter(acceleration, sampleFrequency, 1, 'low');

% isStationary = zeros(size(acceleration));
%
% function [updatedVector, isVectorStationary] = filterNoise(vector, lowerBound, upperBound)
%   updatedVector = vector;
%   isVectorStationary = false;
%   % if vector is in between the lower and upper bounds, it is considered as noise
%   if (vector > lowerBound && vector < upperBound)
%     updatedVector = 0;
%     isVectorStationary = true;
%   endif
% endfunction
%
% thresholds = [-0.1 -0.1 -1; 0.1 0.1 1]; % noise filter threshold for [x, y, z], lower and upper bounds
% for index = 1: updatedNumberOfSamples
%   for vectorIndex = 1: 3
%     [acceleration(index, vectorIndex), isStationary(index, vectorIndex)] = filterNoise(acceleration(index, vectorIndex), thresholds(1, vectorIndex), thresholds(2, vectorIndex));
%   end
% end

% numerically integrate for velocity, and filter
velocity = cumtrapz(time, acceleration);
velocity = myFilter(velocity, sampleFrequency, 0.05, 'high');

% numerically integrate for displacement, and filter
displacement = cumtrapz(time, velocity);
displacement = myFilter(displacement, sampleFrequency, 0.05, 'high');

% plot data
plotData(time, acceleration, velocity, displacement);
