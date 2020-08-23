function [R_theta, R_phi, R_psi, R] = eul2rotm(eul)
%% Euler Angles to Rotation Matrix
% Generates rotation matrices for intrinsic rotations about axes z, x and
% again z, by Euler angles theta, phi and psi, respectively.
%% Calculate Sines and Cosines of Euler Angles
s = sin(eul(:, 1:3));
c = cos(eul(:, 1:3));

%% Generate Rotation Matrices
n = size(eul, 1);
m = floor(size(eul, 2)/3);

R_theta = zeros([3, 3*m, n]);
R_phi   = zeros([3, 3*m, n]);
R_psi   = zeros([3, 3*m, n]);
R       = zeros([3, 3*m, n]);
for i=1:n
    R_theta(1:2, 1:2, i) = [c(i, 1), -s(i, 1);
                            s(i, 1),  c(i, 1)];
    R_theta(3, 3, i)     = 1;
    R_phi(1, 1, i)       = 1;
    R_phi(2:3, 2:3, i)   = [c(i, 2), -s(i, 2);
                            s(i, 2),  c(i, 2)];
    R_psi(1:2, 1:2, i)   = [c(i, 3), -s(i, 3);
                            s(i, 3),  c(i, 3)];
    R_psi(3, 3, i)       = 1;
    R(:, 1:3, i) = R_theta(:, 1:3, i)*R_phi(:, 1:3, i)*R_psi(:, 1:3, i);
    
    if 1 < m
        % Determine first derivatives using chain and product rules.
        R_theta(1:2, 4:5, i) = [-s(i, 1), -c(i, 1);
                                 c(i, 1), -s(i, 1)]*eul(i, 4);
        R_phi(2:3, 5:6, i)   = [-s(i, 2), -c(i, 2);
                                 c(i, 2), -s(i, 2)]*eul(i, 5);
        R_psi(1:2, 4:5, i)   = [-s(i, 3), -c(i, 3);
                                 c(i, 3), -s(i, 3)]*eul(i, 6);
        R(:, 4:6, i) = R_theta(:, 4:6, i)*R_phi(:, 1:3, i)*R_psi(:, 1:3, i) +...
                       R_theta(:, 1:3, i)*R_phi(:, 4:6, i)*R_psi(:, 1:3, i) +...
                       R_theta(:, 1:3, i)*R_phi(:, 1:3, i)*R_psi(:, 4:6, i);
        
        if 2 < m
            % Determine second derivatives using chain and product rules.
            R_theta(1:2, 7:8, i) = [-c(i, 1),  s(i, 1);
                                    -s(i, 1), -c(i, 1)]*eul(i, 4)^2 +...
                                   [-s(i, 1), -c(i, 1);
                                     c(i, 1), -s(i, 1)]*eul(i, 7);
            R_phi(2:3, 8:9, i)   = [-c(i, 2),  s(i, 2);
                                    -s(i, 2), -c(i, 2)]*eul(i, 5)^2 +...
                                   [-s(i, 2), -c(i, 2);
                                     c(i, 2), -s(i, 2)]*eul(i, 8);
            R_psi(1:2, 7:8, i)   = [-c(i, 3),  s(i, 3);
                                    -s(i, 3), -c(i, 3)]*eul(i, 6)^2 +...
                                   [-s(i, 3), -c(i, 3);
                                     c(i, 3), -s(i, 3)]*eul(i, 9);
            R(:, 7:9, i) =   R_theta(:, 7:9, i)*R_phi(:, 1:3, i)*R_psi(:, 1:3, i) +...
                           2*R_theta(:, 4:6, i)*(R_phi(:, 4:6, i)*R_psi(:, 1:3, i) +...
                                                 R_phi(:, 1:3, i)*R_psi(:, 4:6, i)) +...
                             R_theta(:, 1:3, i)*(R_phi(:, 7:9, i)*R_psi(:, 1:3, i) +...
                                               2*R_phi(:, 4:6, i)*R_psi(:, 4:6, i) +...
                                                 R_phi(:, 1:3, i)*R_psi(:, 7:9, i));
        end
        
    end
    
end

end

