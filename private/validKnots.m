function validKnots(Knots, Mask)
%% Validate Knots
% Validates the knots and their mask to construct a spline from.
%% Validate Size
if ~isequal(size(Knots), size(Mask))
    error('Knots and mask dimensions must agree.');
end

if size(Knots, 1) < 1
    error('At least one knot must be given.');
end

if size(Knots, 2) ~= 7
    error('Seven entries must be given per knot.');
end

%% Validate Times
if min(diff(Knots(:, 1))) <= 0
    error('Knot times must be strictly increasing.');
end

end

