function pos = circular(t)
%% Circular
% This function returns a position key generated using the circular
% functions.
%% Generate Keys

pos = [263+2*cos(t), 55+2*sin(t), 10+sin(t)/2,...
          -2*sin(t),    2*cos(t),    cos(t)/2,...
          -2*cos(t),   -2*sin(t),   -sin(t)/2];

end

