function spline = genSpline(Knots, Mask, t_min)
%% Generate Spline
% This function returns a one-dimensional cubic Bezier spline that
% minimizes square acceleration given the constraints.
%% Preprocess Knots
n = size(Knots, 1);

if n == 0
    % No knots given; return zero spline.
    spline = [t_min - 1, t_min;...
              zeros([4, 2])];
    return;
end

t = Knots(:, 1);
x = Knots(:, 2);
v = Knots(:, 3);
tMask = Mask(:, 1);
xMask = Mask(:, 2);
vMask = Mask(:, 3);

if sum(xMask) == 0
    % No positions given; set position at t_min to 0.
    i = find(t == t_min);
    if isempty(i)
        % Add knot at t_min.
        t        =    [t_min; t];
        tMask    =     [true; tMask];
        x        =        [0; x];
        xMask    =     [true; xMask];
        v        =     [v(1); v];
        vMask    = [vMask(1); vMask];
        n        = n + 1;
    else
        x(i)     = 0;
        xMask(i) = true;
    end
end

if n == 1
    % Add knot such that sole segment is linear.
    t     =    [t - 1; t];
    tMask =     [true; true];
    if vMask
        v =        [v; v];
    else
        v =        [0; 0];
    end
    vMask =     [true; true];
    x     = [x - v(1); x];
    xMask =     [true; true];
    n     = n + 1;
end

Knots = [t,     x,     v];
Mask  = [tMask, xMask, vMask];

%% Define Undefined Knots
undef_0 = Knots(~Mask);

if ~isempty(undef_0)
    t = Knots(:, 1)';
    d = diff(t);
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton',...
                                        'Display',          'off');
    fminunc(@J, undef_0, options);
else
    spline = toCanon(Knots);
end

% Energy functional, a.k.a. objective function.
function f = J(var)
    Knots(~Mask) = var;
    spline = toCanon(Knots);
    p_0 = spline(2, 1:end-1);
    p_1 = spline(3, 1:end-1);
    p_2 = spline(4, 1:end-1);
    p_3 = spline(5, 1:end-1);
    s_a = p_0 - 2*p_1 + p_2;
    s_b = p_1 - 2*p_2 + p_3;
    
    f = 12*sum(d.^3.*((s_a).^2 + (s_a).*(s_b) + (s_b).^2));
    
end

%% Linearize Bookends

if isLinear(Knots(1:2, :), spline(2:5, 1))
    % First segment is linear.
else
    % Add linear segment to front.
    t = Knots(1, 1);
    x = Knots(1, 2);
    v = Knots(1, 3);
    
    t_new = t - 1;
    x_new = x - v;
    v_new = v;
    
    Knots = [t_new, x_new, v_new;
             Knots];
    spline = toCanon(Knots);
end

if isLinear(Knots(end-1:end, :), spline(2:5, end))
    % Last segment is linear.
else
    % Add linear segment to back.
    t = Knots(end, 1);
    x = Knots(end, 2);
    v = Knots(end, 3);
    
    t_new = t + 1;
    x_new = x + v;
    v_new = v;
    
    Knots = [Knots;
             t_new, x_new, v_new];
    spline = toCanon(Knots);
end

end

function spline = toCanon(Knots)
%% Convert to Canonical Form
% Converts the given knots to a cubic spline in canonical form.

t = Knots(:, 1)';
x = Knots(:, 2)';
v = Knots(:, 3)';

d = diff(t);

p_0 = x(1:end-1)./d.^3;
p_3 = x(2:end)./d.^3;

p_1 = p_0 + v(1:end-1)./d.^2/3;
p_2 = p_3 - v(2:end)./d.^2/3;

spline = [t;...
          [p_0, p_0(end)];...
          [p_1, p_1(end)];...
          [p_2, p_2(end)];...
          [p_3, p_3(end)]];

end

function bool = isLinear(K, p)
%% Is Linear
% Returns whether the cubic spline segment defined by K or p is linear.
% Returns true if either form is linear; there may be a difference due to
% numerical issues.
%% Check Knots
t = K(:, 1);
x = K(:, 2);
v = K(:, 3);
if (v(1) == v(2)) && (v(2) == (x(2)-x(1))/(t(2)-t(1)))
    bool = true;
    return;
end

%% Check Control Points
p_0 = p(1);
p_1 = p(2);
p_2 = p(3);
p_3 = p(4);
if ((p_1 - p_0) == (p_3 - p_2)) && (3*(p_3 - p_2) == (p_3 - p_0))
   bool = true;
   return;
end

%% Return False
bool = false;

end

