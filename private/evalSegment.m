function x = evalSegment(p, a, b, t, d)
%% Evaluate Segment
% This function evaluates the dth derivative at t of a segment of a spline
% defined as a cubic function by control points p and corresponding segment
% boundaries a and b.

if isempty(t)
    x = [];
    return;
end

if d == 0
    % Evaluate 0th derivative.
    x = [   (b-t).^3,...
          3*(b-t).^2.*(t-a),...
          3*(b-t).*(t-a).^2,...
                      (t-a).^3]*p;
elseif d == 1
    % Evaluate 1st derivative.
    x = [-3*(b-t).^2,...
          3*(b-t).^2-6*(b-t).*(t-a),...
                     6*(b-t).*(t-a)-3*(t-a).^2,...
                                    3*(t-a).^2]*p;
elseif d == 2
    % Evaluate 2nd derivative.
    x = [  6*(b-t),...
         -12*(b-t)+6*(t-a),...
           6*(b-t)-12*(t-a),...
                    6*(t-a)]*p;
else
    error(sprintf('Could not evaluate derivative of order %g.', d));
end

end

