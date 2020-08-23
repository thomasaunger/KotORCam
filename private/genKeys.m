function [position, orientation] = genKeys(t, pos, eul,...
                                           r_theta, r_phi, r_psi)
%% Generate Keys
% Generates keys given the sample data.
%% Generate Orientation Key
% Convert Euler angles to rotation matrices.
[R_theta, R_phi, ~, R] = eul2rotm(eul);

% Number of samples.
n = numel(t);

% (m-1) is the greatest order of derivative stored.
m_p = floor(size(pos, 2)/3);
m_r = floor(size(eul, 2)/3);

A = rotm2axang(R(:, 1:3, :));
A(:, 1:3) = bsxfun(@rdivide, A(:, 1:3), sqrt(sum(A(:, 1:3).^2, 2)));

orientation = [t, A];
if 1 < m_r
    % Include first derivative.
    orientation = [orientation, -reshape(R(:, 6, :), [3, n])'];
    if 2 < m_r
        % Include second derivative.
        orientation = [orientation, -reshape(R(:, 9, :), [3, n])'];
    end
end

%% Generate Position Key
if any([r_theta; r_phi; r_psi], 1)
    % Rotational parallax causes nonzero change in position.
    r = parallax(R_theta, R_phi, R, r_theta, r_phi, r_psi);
    m_min = min([m_p, m_r]);
    pos = pos(:, 1:3*m_min) + r(:, 1:3*m_min);
end

position = [t, pos];

end

