function validSpline(spline, Knots, Mask, dim)
%% Validate Spline
% Validates a given spline by comparing it to the knots.
%% Parse Knots
t = Knots(:, 1);
x = Knots(:, 2);
v = Knots(:, 3);

xMask = Mask(:, 2);
vMask = Mask(:, 3);

%% Validate Positions
k = x(xMask);
s = evalSpline(spline, t(xMask), 0);
if ~isempty(k) && ~isempty(s) && ~isequal(k, s)
    list = sprintf('%-12g%-12g%-12g%-12g\n',...
                   [t(xMask), k, s, k - s]');
    warning(['Spline positions do not match knot values.\n'...
             't           knots_%s     spline_%s    difference\n'...
             '%s'], dim, dim, list);
end

%% Validate Velocities
k = v(vMask);
s = evalSpline(spline, t(vMask), 1);
if ~isempty(k) && ~isempty(s) && ~isequal(k, s)
    list = sprintf('%-12g%-12g%-12g%-12g\n',...
                   [t(vMask), k, s, k - s]');
    warning(['Spline velocities do not match knot values.\n'...
             't           knots_%s     spline_%s    difference\n'...
             '%s'], dim, dim, list);
end

end

