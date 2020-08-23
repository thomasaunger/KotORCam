function samples = cubicBezier3(t, fileKnots, fileMask)
%% Cubic Bezier
% This function returns samples generated with a cubic Bezier spline.
%% Load Knots
fprintf(sprintf('\n    Loading %s...', fileKnots));

Knots = load(sprintf('%s.txt', fileKnots));
Mask = logical(load(sprintf('%s.txt', fileMask)));

%% Validate Knots
fprintf(sprintf('\n    Validating %s...', fileKnots));

validKnots(Knots, Mask);

%% Parse Knots and Remove Undefined Knots
fprintf(sprintf('\n    Parsing %s...', fileKnots));

Knots = Knots(Mask(:, 1), :);
Mask = Mask(Mask(:, 1), :);

xTrue = Mask(:, 2) | Mask(:, 5);
xKnots = Knots(xTrue, [1, 2, 5]);
xMask = Mask(xTrue, [1, 2, 5]);

yTrue = Mask(:, 3) | Mask(:, 6);
yKnots = Knots(yTrue, [1, 3, 6]);
yMask = Mask(yTrue, [1, 3, 6]);

zTrue = Mask(:, 4) | Mask(:, 7);
zKnots = Knots(zTrue, [1, 4, 7]);
zMask = Mask(zTrue, [1, 4, 7]);

%% Generate Splines
fprintf('\n    Generating splines...');

xSpline = genSpline(xKnots, xMask, t(1));
ySpline = genSpline(yKnots, yMask, t(1));
zSpline = genSpline(zKnots, zMask, t(1));

%% Validate Splines
fprintf('\n    Validating splines...');

validSpline(xSpline, xKnots, xMask, '1');
validSpline(ySpline, yKnots, yMask, '2');
validSpline(zSpline, zKnots, zMask, '3');

%% Evaluate Splines
fprintf('\n    Evaluating splines...');

d = 0;
x = evalSpline(xSpline, t, d);
y = evalSpline(ySpline, t, d);
z = evalSpline(zSpline, t, d);

d = 1;
v_x = evalSpline(xSpline, t, d);
v_y = evalSpline(ySpline, t, d);
v_z = evalSpline(zSpline, t, d);

d = 2;
a_x = evalSpline(xSpline, t, d);
a_y = evalSpline(ySpline, t, d);
a_z = evalSpline(zSpline, t, d);

%% Return Samples
fprintf('\n    Generating samples...');

samples = [  x,   y,   z,...
           v_x, v_y, v_z,...
           a_x, a_y, a_z];

fprintf('\n');

end

