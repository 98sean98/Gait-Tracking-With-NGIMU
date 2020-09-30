clc
clear
close all;

%% Import data

sessionData = importSession('TrackingSession');

samplePeriod = 1 / 400; % 400 Hz
[sessionData, time] = resampleSession(sessionData, samplePeriod); % resample data so that all measuremnts share the same time vector

acceleration = sessionData.(sessionData.deviceNames{1}).earth.vector * 9.81; % convert to m/s/s

numberOfSamples = length(time);

%% Identify stationary periods

lateralThreshold = 0.3; % lateral acceleration threshold in m/s/s
verticalThreshold = 1; % vertical acceleration threshold in m/s/s

% Determine as moving if acceleration greater than theshold
isMoving = abs(acceleration(:,1)) > lateralThreshold | ...
           abs(acceleration(:,2)) > lateralThreshold | ...
           abs(acceleration(:,3)) > verticalThreshold;

% Add margin to extend each period identified as moving
marginSizeInSamples = ceil(0.1 / samplePeriod); % margin = 0.1 seconds
isMovingWithMargin = isMoving;
for sampleIndex = 1 : (numberOfSamples - marginSizeInSamples)
    if(isMoving(sampleIndex) == 1)
        isMovingWithMargin(sampleIndex : (sampleIndex + marginSizeInSamples)) = 1;
    end
end
for sampleIndex = (numberOfSamples - marginSizeInSamples) : -1 : (marginSizeInSamples + 1)
    if(isMoving(sampleIndex) == 1)
        isMovingWithMargin((sampleIndex - marginSizeInSamples) : sampleIndex) = 1;
    end
end

% Stationary periods are non-moving periods
isStationary = ~isMovingWithMargin;

%% Calculate velocity

velocity = zeros(size(acceleration));
for sampleIndex = 2 : numberOfSamples
    velocity(sampleIndex, :) = velocity(sampleIndex - 1, :) + acceleration(sampleIndex, :) * samplePeriod;
    if(isStationary(sampleIndex) == 1)
        velocity(sampleIndex, :) = [0 0 0]; % force velocity to zero if stationary
    end
end

%% Remove velocity drift

stationaryStartIndexes = find([0; diff(isStationary)] == -1);
stationaryEndIndexes = find([0; diff(isStationary)] == 1);

velocityDrift = zeros(size(velocity));
for stationaryEndIndexesIndex = 1:numel(stationaryEndIndexes)

    velocityDriftAtEndOfMovement = velocity(stationaryEndIndexes(stationaryEndIndexesIndex) - 1, :);
    numberOfSamplesDuringMovement = (stationaryEndIndexes(stationaryEndIndexesIndex) - stationaryStartIndexes(stationaryEndIndexesIndex));
    velocityDriftPerSample = velocityDriftAtEndOfMovement / numberOfSamplesDuringMovement;

    ramp = (0 : (numberOfSamplesDuringMovement - 1))';
    velocityDriftDuringMovement = [ramp * velocityDriftPerSample(1), ...
                                   ramp * velocityDriftPerSample(2), ...
                                   ramp * velocityDriftPerSample(3)];

    velocityIndexes = stationaryStartIndexes(stationaryEndIndexesIndex):stationaryEndIndexes(stationaryEndIndexesIndex) - 1;
    velocity(velocityIndexes, :) = velocity(velocityIndexes, :) - velocityDriftDuringMovement;
end

%% Calculate position

position = zeros(size(velocity));
for sampleIndex = 2 : numberOfSamples
    position(sampleIndex, :) = position(sampleIndex - 1, :) + velocity(sampleIndex, :) * samplePeriod;
end

%% Plot data
plotData(time, acceleration, velocity, position);