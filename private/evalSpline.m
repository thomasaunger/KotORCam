function x = evalSpline(spline, t, d)
%% Evaluate Spline
% Returns the dth derivative of the given cubic Bezier spline in canonical
% form at t.
%% Evaluate t < t_1.
t_1 = spline(1, 1);
t_2 = spline(1, 2);
p = spline(2:end, 1);
x = evalSegment(p, t_1, t_2, t(t < t_1), d);

%% Evaluate t_1 <= t < t_{n-1}.
n = size(spline, 2);
for i = 1:n-2;
    % Evaluate t_i <= t < t_ii.
    t_i = spline(1, i);
    t_ii = spline(1, i+1); % = t_{i+1}
    p = spline(2:end, i);
    x_i = evalSegment(p, t_i, t_ii, t((t_i <= t) & (t < t_ii)), d);
    x = [x; x_i];
end

%% Evaluate t_{n-1} <= t.
t_nm1 = spline(1, end-1);                             % = t_{n-1}
t_n = spline(1, end);
p = spline(2:end, end);
x_nm1 = evalSegment(p, t_nm1, t_n, t(t_nm1 <= t), d); % = x_{n-1}
x = [x; x_nm1];

end

