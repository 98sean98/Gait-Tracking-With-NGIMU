clc
clear
close all

sessionData = importSession('TrackingSession');

time = sessionData.(sessionData.deviceNames{1}).linear.time;
acceleration = sessionData.(sessionData.deviceNames{1}).linear.vector * 9.81; % convert from g to m/s/s
sampleFrequency = 400;

a = acceleration(:, 1);

a_filtered = myFilter(a, sampleFrequency, 2.5, 'low');

v_unfiltered = cumtrapz(time, a);

v = cumtrapz(time, a_filtered);

v_filtered = myFilter(v, sampleFrequency, 0.1, 'high');

d_unfiltered = cumtrapz(time, v_unfiltered);

d = cumtrapz(time, v_filtered);
d_filtered = myFilter(d, sampleFrequency, 0.1, 'high');

figure;
hold on;
plot(time, a, 'b');
plot(time, a_filtered, 'r');

figure;
hold on;
plot(time, v_unfiltered, 'b');
plot(time, v, 'g');
plot(time, v_filtered, 'r');

figure;
hold on;
% plot(time, d_unfiltered, 'b');
plot(time, d, 'g');
plot(time, d_filtered, 'r');
