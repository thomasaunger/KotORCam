function [position, orientation] = compressKeys(position, orientation)
%% Compress Keys
% This function compresses the position and orientation keys, such that
% redundant rows are removed.
%% Convert to Single Precision
position    = single(position);
orientation = single(orientation);

%% Compress Position Key
% Number of position samples.
n_p = size(position, 1);

% Find indices of contributing position samples, i.e., position samples
% that are a nonlinear interpolation of their neighboring samples. The
% first and the last sample contribute if they are different from their
% neighboring sample. If all samples are equal, only the first contributes.
if n_p == 1
    i = true;
elseif n_p == 2
    i = [true; any(diff(position(:, 2:4)), 2)];
else
    i          = false([n_p, 1]);
    dp         = diff(position(:, 2:4));
    dt         = diff(position(:, 1), 1);
    i(2:end-1) = any(diff(bsxfun(@rdivide, dp, dt)), 2);
    i(1)       = any(dp(1), 2);
    i(end)     = any(dp(end), 2);
    if ~any(i)
        i(1) = true;
    end
end

% Return those samples.
position = position(i, :);

% Number of removed position samples.
n_p_removed = n_p - sum(i);

%% Compress Orientation Key
% Number of orientation samples.
n_r = size(orientation, 1);

% Find indices of contributing orientation samples, i.e., samples that are
% different from their preceding or following sample. The same holds true
% for the first and the last sample. If all samples are equal, only the
% first contributes.
if n_r == 1
    i = true;
elseif n_r == 2
    i = [true; any(diff(orientation(:, 2:5)), 2)];
else
    i          = false([n_r, 1]);
    i(2:end)   = any(diff(orientation(:, 2:5)), 2);
    i(1)       = i(2);
    i(2:end-1) = i(2:end-1) | i(3:end);
    if ~any(i)
        i(1) = true;
    end
end

% Return those samples.
orientation = orientation(i, :);

% Number of removed orientation samples.
n_r_removed = n_r - sum(i);

%% Print Results
% Number of decimal digits of the largest number of removed samples.
d = numel(num2str(max([n_p_removed, n_r_removed])));

msg_p = sprintf('\n    Removed %%%dd/%%d position samples.', d);
fprintf(msg_p, n_p_removed, n_p);

msg_r = sprintf('\n    Removed %%%dd/%%d orientation samples.\n', d);
fprintf(msg_r, n_r_removed, n_r);

end

