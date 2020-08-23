function qi = quatinterp(p, q, f, method)
%% Quaternion Interpolation
% Calculates the quaternion interpolation between two normalized
% quaternions p and q by interval fraction f.
% p and q are the two extremes between which the function calculates the
% quaternion.
%% Validate Inputs
if ~strcmp(method, 'slerp')
    error('Unknown quaternion interpolation method "%s".', method);
end

if (f < 0) || (1 < f)
    error('Interpolation interval fraction must be in interval [0, 1].');
end

%% Interpolate
% https://en.wikipedia.org/wiki/Slerp#Source_Code

c = dot(p, q);

threshold = 0.9995;
if threshold < c
    % p and q are very close together; interpolate linearly.
    qi = normr(p + f*(q - p));
    return;
end

if c < 0
    % p and q have opposite handedness. Reverse one quaternion to ensure
    % slerp takes the shorter path.
    q = -q;
    c = -c;
end

% Stay within domain of acos.
if c < -1
    c = -1;
elseif 1 < c
    c = 1;
end

% Angle between p and q.
theta_0 = acos(c);

% Angle between p and qi.
theta = theta_0*f;

% Create orthonormal basis {p, r}.
r = normr(q - c*p);

qi = p*cos(theta) + r*sin(theta);

end

