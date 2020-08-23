function validSamples(t, pos, eul, r_theta, r_phi, r_psi)
%% Validate Samples
% Validates the time, position, Euler angle and r samples.
%% Validate t
% Number of samples.
n = size(t, 1);

if n < 1
    error('t must have at least one row.');
end

if size(t, 2) ~= 1
    error('t must have one column.');
end

%% Validate pos
if size(pos, 1) ~= n
    error('pos and t must have an equal number of rows.');
end

if size(pos, 2) < 3
    error('pos must have at least three columns.');
end

%% Validate eul
if size(eul, 1) ~= n
    error('eul and t must have an equal number of rows.');
end

if size(eul, 2) < 3
    error('eul must have at least three columns.');
end

%% Validate r
if ~isequal(size(r_theta), [3, 1]) ||...
   ~isequal(size(r_phi),   [3, 1]) ||...
   ~isequal(size(r_psi),   [3, 1])
    error('r_theta, r_phi and r_psi must be 3-by-1 vectors.');
end

end

