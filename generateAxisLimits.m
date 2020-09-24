function axisLimits = generateAxisLimits(x, y)
  minX = min(x);
  maxX = max(x);
  minY = min(y);
  maxY = max(y);
  
  axisLimits = zeros(1, 4);
  
  if minX < minY
    axisLimits(1) = minX - 1;
    axisLimits(3) = minX - 1;
  else
    axisLimits(1) = minY - 1;
    axisLimits(3) = minY - 1;
  endif
  
  if maxX > maxY
    axisLimits(2) = maxX + 1;
    axisLimits(4) = maxX + 1;
  else
    axisLimits(2) = maxY + 1;
    axisLimits(4) = maxY + 1;
  endif
endfunction
