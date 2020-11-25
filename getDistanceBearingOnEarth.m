function [distance, bearing] = getDistanceBearingOnEarth(loc1, loc2)
  % If two inputs are given, display error
  if ~isequal(nargin, 2)
      error('User must supply two location inputs')
      
  % If two inputs are given, handle data
  else
      
      locs = {loc1 loc2};     % Combine inputs to make checking easier
      
      % Cycle through to check both inputs
      for i = 1:length(locs)
                  
          % Check inputs and convert to decimal if needed
          if ischar(locs{i})
              
              % Parse lat and long info from current input
              temp = regexp(locs{i}, ',', 'split');
              lat = temp{1}; lon = temp{2};
              clear temp
              locs{i} = [];           % Remove string to make room for array
              
              % Obtain degrees, minutes, seconds, and hemisphere
              temp = regexp(lat, '(\d+)\D+(\d+)\D+(\d+)(\w?)', 'tokens');
              temp = temp{1};
              
              % Calculate latitude in decimal degrees
              locs{i}(1) = str2double(temp{1}) + str2double(temp{2})/60 + ...
                  str2double(temp{3})/3600;
              
              % Make sure hemisphere was given
              if isempty(temp{4})
                  error('No hemisphere given')
              % If latitude is south, make decimal negative
              elseif strcmpi(temp{4}, 'S')
                  locs{i}(1) = -locs{i}(1);
              end
              
              clear temp
              % Obtain degrees, minutes, seconds, and hemisphere
              temp = regexp(lon, '(\d+)\D+(\d+)\D+(\d+)(\w?)', 'tokens');
              temp = temp{1};
              
              % Calculate longitude in decimal degrees
              locs{i}(2) = str2double(temp{1}) + str2double(temp{2})/60 + ...
                  str2double(temp{3})/3600;
              
              % Make sure hemisphere was given
              if isempty(temp{4})
                  error('No hemisphere given')
                  
              % If longitude is west, make decimal negative
              elseif strcmpi(temp{4}, 'W')
                  locs{i}(2) = -locs{i}(2);
              end
              
              clear temp lat lon
          end
      end
  end
  % Check that both cells are a 2-valued array
  if any(cellfun(@(x) ~isequal(length(x),2), locs))
      error('Incorrect number of input coordinates')
  end
  % Convert all decimal degrees to radians
  locs = cellfun(@(x) x .* pi./180, locs, 'UniformOutput', 0);
  
  % Begin calculation for distance
  R = 6371;                                   % Earth's radius in km
  delta_lat = locs{2}(1) - locs{1}(1);        % difference in latitude
  delta_lon = locs{2}(2) - locs{1}(2);        % difference in longitude
  a = sin(delta_lat/2)^2 + cos(locs{1}(1)) * cos(locs{2}(1)) * ...
      sin(delta_lon/2)^2;
  c = 2 * atan2(sqrt(a), sqrt(1-a));
  distance = R * c * 1000;                    % distance in meters
  
  % Begin calculation for bearing
  bearing = atan2(sin(delta_lon)*cos(locs{2}(2)), cos(locs{1}(1))*sin(locs{2}(1)) - sin(locs{1}(1))*cos(locs{2}(1))*cos(delta_lon));
endfunction