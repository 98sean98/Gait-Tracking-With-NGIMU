function plotData(time, acceleration, velocity, position, isStationary)
  figure;
  % acceleration
  subplots(1) = subplot(3, 1, 1);
  hold on;
  plot(time, acceleration(:, 1), 'r');
  plot(time, acceleration(:, 2), 'g');
  plot(time, acceleration(:, 3), 'b');
  plot(time, isStationary * 10, 'k');
  title('Acceleration');
  xlabel('seconds');
  ylabel('m/s/s');
  legend('x', 'y', 'z', 'isStationary');

  % velocity
  subplots(2) = subplot(3, 1, 2);
  hold on;
  plot(time, velocity(:, 1), 'r');
  plot(time, velocity(:, 2), 'g');
  plot(time, velocity(:, 3), 'b');
  title('Velocity');
  xlabel('seconds');
  ylabel('m/s');
  legend('x', 'y', 'z');

  % displacement
  subplots(3) = subplot(3, 1, 3);
  hold on;
  plot(time, position(:, 1), 'r');
  plot(time, position(:, 2), 'g');
  plot(time, position(:, 3), 'b');
  title('Position');
  xlabel('seconds');
  ylabel('m');
  legend('x', 'y', 'z');

  linkaxes(subplots, 'x');

  % maps
  x = position(:, 1);
  y = position(:, 2);
  z = position(:, 3);

  figure;
  % 2D map
  plot(y, x, 'r');
  title('2D map');
  xlabel('y');
  ylabel('x');
  legend('path');
  axisLimits = generateAxisLimits(y, x);
  axis(axisLimits);

  figure;
  % elevation
  plot(position(:, 1), position(:, 3), 'b');
  title('Elevation');
  xlabel('x');
  ylabel('z');
  legend('path');
  axisLimits = generateAxisLimits(x, z);
  axis(axisLimits);

  figure;
  % 3D map
  plot3(position(:, 2), position(:, 1), position(:, 3), 'color', 'r', 'linewidth', 3, 'marker', '.', 'markersize', 5);
  axis equal;
  title('3D map');
  xlabel('y');
  ylabel('x');
  zlabel('z');
endfunction
