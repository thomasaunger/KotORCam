function eul = followSimple(B, A, psi)
%% Follow Subject (Simple)
% Generates new Euler angles theta and phi (psi remains unchanged) such
% that the camera follows subject position b from camera position a.
%% Validate Inputs
% Validate rows.
n_B   = size(B, 1);
n_A   = size(A, 1);
n_psi = size(psi, 1);

n_min = min([n_B, n_A, n_psi]);
n_max = max([n_B, n_A, n_psi]);

if n_min ~= n_max
    error('B, A and psi must have an equal number of rows.');
else
    n = n_min;
end

% Validate columns.
m_B   = floor(size(B, 2)/3);
m_A   = floor(size(A, 2)/3);
m_psi = size(psi, 2);

if m_B < 1 || m_A < 1
    error('B and A must have at least three columns.');
elseif m_psi < 1
    error('psi must have at least one column.');
else
    m = min([m_B, m_A, m_psi]);
end

%% Announce Limited Functionality
fprintf('\n');
warning(['The followSimple function currently does not supply '...
         'derivatives.']);
m = 1;

%% Generate Euler Angles
theta = zeros([n, m]);
phi   = zeros([n, m]);

% Normalize B - A to unit vectors U.
U = B(:, 1:3) - A(:, 1:3);
U = bsxfun(@rdivide, U, sqrt(sum(U.^2, 2)));

phi(:, 1)   = real(acos(-U(:, 3)));
theta(:, 1) = real(acos(U(:, 2)./sin(phi(:, 1))));

% Shift to quadrants I and IV if 0 < U_x, i.e., the camera looks in the
% positive x direction.
i = 0 < U(:, 1);            % = 0 < U_x
theta(i, :) = -theta(i, :); % shift angle and any derivatives

%% Validate Results
% Check for undefined values.
i_theta = not(any(isnan(theta(:, 1)), 1));
i_phi   = not(any(isnan(phi(:, 1)), 1));
i_d     = i_theta && i_phi;

% Check for unbounded values.
i_theta = not(any(isinf(theta(:, 1)), 1));
i_phi   = not(any(isinf(phi(:, 1)), 1));
i_b     = i_theta && i_phi;

if ~(i_d && i_b)
    error('No defined, bounded solution found.');
end

%% Compile Results
eul = [theta(:, 1), phi(:, 1), psi(:, 1)];

if 1 < m
    % Include first derivative.
    eul = [eul, theta(:, 2), phi(:, 2), psi(:, 2)];
    
    if 2 < m
        % Include second derivative.
        eul = [eul, theta(:, 3), phi(:, 3), psi(:, 3)];
    end
    
end

end

