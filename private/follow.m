function eul = follow(B, A, psi, r_theta, r_phi, r_psi)
%% Follow Subject
% Generates new Euler angles theta and phi (psi remains unchanged) such
% that the camera follows subject position b from camera position a + r.
%% Validate Inputs
% Validate r.
if ~isequal(size(r_theta), [3, 1]) ||...
   ~isequal(size(r_phi),   [3, 1]) ||...
   ~isequal(size(r_psi),   [3, 1])
    error('r_theta, r_phi and r_psi must be 3-by-1 vectors.');
end

% Detect degenerate case.
if not(any([r_theta; r_phi; r_psi], 1))
    eul = followSimple(B, A, psi);
    return;
end

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
warning(['The follow function currently does not supply derivatives '...
         'in the non-degenerate case.']);
m = 1;

%% Calculate Constants k

k_1 = (r_psi(2)*cos(psi(:, 1)) + r_psi(1)*sin(psi(:, 1)) + r_phi(2));
k_2 = r_phi(3) + r_psi(3);
k_3 = (r_psi(1)*cos(psi(:, 1)) - r_psi(2)*sin(psi(:, 1)) +...
       r_theta(1) + r_phi(1));

if 1 < m
    % Calculate first derivative.
    k_1 = [k_1,...
           (-r_psi(2)*sin(psi(:, 1)) +...
             r_psi(1)*cos(psi(:, 1))).*psi(:, 2)];
    k_3 = [k_3,...
           (-r_psi(1)*sin(psi(:, 1)) -...
             r_psi(2)*cos(psi(:, 1))).*psi(:, 2)];
    
    if 2 < m
        % Calculate second derivative.
        k_1 = [ k_1,...
               (k_1(:, 2).*psi(:, 2) +...
                (-r_psi(2)*sin(psi(:, 1)) +...
                  r_psi(1)*cos(psi(:, 1))).*psi(:, 2).*psi(:, 3))];
        k_3 = [ k_3,...
               (k_3(:, 2).*psi(:, 2) +...
                (-r_psi(1)*sin(psi(:, 1)) -...
                  r_psi(2)*cos(psi(:, 1))).*psi(:, 2).*psi(:, 3))];
    end
    
end

%% Generate Euler Angles to Follow Subject
delta = zeros([n, m, 8]);
theta = zeros([n, m, 8]);
phi   = zeros([n, m, 8]);

h = waitbar(0, 'Generating Euler angles to follow subject...');

for i = 1:n
    [delta(i, :, :),...
     theta(i, :, :),...
     phi(i, :, :)] = findDelta(B(i, :), A(i, :), r_theta,...
                               k_1(i, :), k_2, k_3(i, :));
    
    % Indicate progress.
    waitbar(i/n);
end

delete(h);

%% Validate Results
% Find defined pages.
i_theta = find(not(any(isnan(theta(:, 1, :)), 1)));
i_phi   = find(not(any(isnan(phi(:, 1, :)), 1)));
i_d     = intersect(i_theta, i_phi);

% Find bounded pages.
i_theta = find(not(any(isinf(theta(:, 1, :)), 1)));
i_phi   = find(not(any(isinf(phi(:, 1, :)), 1)));
i_b     = intersect(i_theta, i_phi);

% Find real pages.
i_theta = find(not(any(imag(theta(:, 1, :)), 1)));
i_phi   = find(not(any(imag(phi(:, 1, :)), 1)));
i_r     = intersect(i_theta, i_phi);

% Find defined, bounded, real pages.
i = intersect(i_d, intersect(i_b, i_r));

if isempty(i)
    error('No defined, bounded, real solution found.');
else
    p = i(1);
    % Note: there may be other solutions, i.e., i(2), i(3), etc.
end

%% Compile Results
eul = [theta(:, 1, p), phi(:, 1, p), psi(:, 1)];

if 1 < m
    % Include first derivative.
    eul = [eul, theta(:, 2, p), phi(:, 2, p), psi(:, 2)];
    
    if 2 < m
        % Include second derivative.
        eul = [eul, theta(:, 3, p), phi(:, 3, p), psi(:, 3)];
    end
    
end

end

function [delta, theta, phi] = findDelta(b, a, r_theta, k_1, k_2, k_3)
delta_0 = norm(b(1:3) - a(1:3));
options = optimoptions('fminunc', 'Algorithm', 'quasi-newton',...
                                    'Display',          'off');

m = size(k_1, 2);

delta = zeros([1, m, 8]);
theta = zeros([1, m, 8]);
phi   = zeros([1, m, 8]);
k_4   = zeros([1, m, 8]);

for i = 1:8
    delta(1, 1, i) = fminunc(@J, delta_0, options);
end

% Shift to quadrants III and IV if b_y - (a_y + r_y) < 0, i.e., the camera
% looks in the negative y direction.
b_y = b(2);
a_y = a(2);
r_y = k_3(1)*sin(theta(1, 1, :)) + k_4(1, 1, :).*cos(theta(1, 1, :));
i   = (b_y - (a_y + r_y)) < 0;        % = b_y - (a_y + r_y) < 0
theta(1, :, i) = -theta(1, :, i);     % shift angle and any derivatives
theta(1, 1, i) = pi + theta(1, 1, i); % new angle comes out as pi - theta

function j = J(delta)
    i_phi   = mod(i-1, 4) + 1;
    i_theta = floor((i-1)/4) + 1;
    
    phi(1, 1, i)   = findPhi(b, a, r_theta, k_1(1), k_2, i_phi, delta);
    
    k_4(1, 1, i)   = r_theta(2) - k_2*sin(phi(1, 1, i)) +...
                     k_1(1)*cos(phi(1, 1, i));
    
    theta(1, 1, i) = findTheta(b, a, k_3(1), k_4(1, 1, i), i_theta,...
                               delta, phi(1, 1, i));
    
    r = [(k_3(1)*cos(theta(1, 1, i)) -...
          k_4(1, 1, i)*sin(theta(1, 1, i))),...
         (k_3(1)*sin(theta(1, 1, i)) +...
          k_4(1, 1, i)*cos(theta(1, 1, i))),...
         (k_1(1)*sin(phi(1, 1, i))   +...
          k_2*cos(phi(1, 1, i)) + r_theta(3))];
    j = (delta - norm(b(1:3) - (a(1:3) + r))).^2;
end

end

function phi = findPhi(b, a, r_theta, k_1, k_2, i_phi, delta)
% Calculate determinant.
D = (k_2 - delta)^2 - (b(3) - (a(3) + r_theta(3)))^2;

% Calculate phi.
f = (b(3) - (a(3) + r_theta(3)))*(k_2 - delta);
g = k_1*sqrt(D);
h = (k_2 - delta)^2 + k_1^2;

if mod(i_phi-1, 2) == 0
    phi = acos((f + g)/h);
else
    phi = acos((f - g)/h);
end

if 2 < i_phi
    phi = -phi;
end

end

function theta = findTheta(b, a, k_3, k_4, i_theta, delta, phi)
% Calculate common constant.
h = 2*(k_3^2 + k_4^2) + delta^2 - delta^2*cos(2*phi) +...
    4*k_4*delta*sin(phi);

% Calculate determinant.
D = 2*(h - 2*(b(1) - a(1))^2);

% Calculate theta.
f = -2*(b(1) - a(1))*(k_4 + delta*sin(phi));
g = k_3*sqrt(D);
if i_theta == 1
    theta = asin((f + g)/h);
else
    theta = asin((f - g)/h);
end
    
end

