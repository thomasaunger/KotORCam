function validKeys(position, orientation)
%% Validate Keys
% Validates the position and orientation keys.
%% Validate Position Key
if size(position, 1) < 1
    error('position must have at least one row.');
end

if size(position, 2) < 4
    error('position must have at least four columns.');
end

if ~isa(position, 'single')
    error('Data type of position must be single-precision.');
end

if min(diff(position(:, 1))) <= 0
    error('position times must be strictly increasing.');
end

%% Validate Orientation Key
if size(orientation, 1) < 1
    error('orientation must have at least one row.');
end

if size(orientation, 2) < 5
    error('orientation must have at least five columns.');
end

if ~isa(orientation, 'single')
    error('Data type of orientation must be single-precision.');
end

if min(diff(orientation(:, 1))) <= 0
    error('orientation times must be strictly increasing.');
end

end

