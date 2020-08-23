function r = parallax(R_theta, R_phi, R, r_theta, r_phi, r_psi)
%% Parallax
% Calculates rotational parallax.

n = size(R_theta, 3);
m = floor(size(R_theta, 2)/3);

rr_theta = zeros([n, 3*m]);
rr_phi   = zeros([n, 3*m]);
rr_psi   = zeros([n, 3*m]);
for i = 1:n
    rr_theta(i, 1:3) = (R_theta(:, 1:3, i)*...
                        r_theta)';
    rr_phi(i, 1:3)   = (R_theta(:, 1:3, i)*...
                        R_phi(:, 1:3, i)*...
                        r_phi)';
    rr_psi(i, 1:3)   = (R(:, 1:3, i)*...
                        r_psi)';
    
    if 1 < m
        % Determine first derivatives using chain and product rules.
        rr_theta(i, 4:6) = (R_theta(:, 4:6, i)*...
                            r_theta)';
        rr_phi(i, 4:6)   = (R_theta(:, 4:6, i)*...
                            R_phi(:, 1:3, i)*...
                            r_phi)' +...
                           (R_theta(:, 1:3, i)*...
                            R_phi(:, 4:6, i)*...
                            r_phi)';
        rr_psi(i, 4:6)   = (R(:, 4:6, i)*...
                            r_psi)';
        
        if 2 < m
            % Determine second derivatives using chain and product rules.
            rr_theta(i, 7:9) =   (R_theta(:, 7:9, i)*...
                                  r_theta)';
            rr_phi(i, 7:9)   =   (R_theta(:, 7:9, i)*...
                                  R_phi(:, 1:3, i)*...
                                  r_phi)' +...
                               2*(R_theta(:, 4:6, i)*...
                                  R_phi(:, 4:6, i)*...
                                  r_phi)' +...
                                 (R_theta(:, 1:3, i)*...
                                  R_phi(:, 7:9, i)*...
                                  r_phi)';
            rr_psi(i, 7:9)   =   (R(:, 7:9, i)*...
                                  r_psi)';
        end
        
    end

end

r = rr_theta + rr_phi + rr_psi;

end

