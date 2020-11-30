clc
clear
close all

table = csvread('linear.csv');
sampleFrequency = 400;

time = table(:, 1);
a = table(:, 2) * 9.81;

a_filtered = myFilter(a, sampleFrequency, 1, 'low');

v_without_a_filter = cumtrapz(time, a);

v = cumtrapz(time, a_filtered);

v_filtered = myFilter(v, sampleFrequency, 0.05, 'high');

d = cumtrapz(time, v);

figure;
hold on;
plot(time, a);
plot(time, a_filtered);
