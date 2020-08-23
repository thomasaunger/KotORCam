function kotorCam(camName)
%% KotORCam
% This function writes a camera model to an MDL file for use in _Star
% Wars(R): Knights of the Old Republic(TM)_ (_KotOR_).
%% Generate Samples
fprintf('Generating samples...');

% Sample frequency.
h = 2; % Hz

% Sample period.
p = 1/h;

% Generate time samples.
t_max = 30;
t     = (0:p:t_max)';

% Generate position samples.
pos = cubicBezier3(t, 'pKnots', 'pMask');

% Generate Euler angle samples.
eul = cubicBezier3(t, 'rKnots', 'rMask')*pi/180;

% pos + r_theta + r_phi + r_psi = center of perspective
r_theta = [    0;     0;  0.25];
r_phi   = [-0.25;  0.25;     0];
r_psi   = [ 0.25;  0.25; -0.25];

% Replace theta and phi values to follow subject.
sub = cubicBezier3(t, 'sKnots', 'sMask');
psi = [eul(:, 3), eul(:, 6), eul(:, 9)];
eul = follow(sub, pos, psi, r_theta, r_phi, r_psi);

%% Validate Samples
fprintf('\nValidating samples...');

validSamples(t, pos, eul, r_theta, r_phi, r_psi);

%% Generate Keys
fprintf('\nGenerating keys...');

[position, orientation] = genKeys(t, pos, eul, r_theta, r_phi, r_psi);

% position = [t,   x,   y,   z,   VA]
% VA       =    [v_x, v_y, v_z,   A]
% A        =    [a_x, a_y, a_z]
% Column vector t contains temporal coordinates. Column vectors x, y and z
% contain spatial coordinates.
% Matrix VA is optional. Any data therein is only used for visualization.
% Column vectors v_x, v_y and v_z contain velocity data.
% Matrix A is optional. Column vectors a_x, a_y and a_z contain
% acceleration data.

% orientation = [t,   x,   y,   z,   a,   VA]
% VA          =    [v_x, v_y, v_z,   A]
% A           =    [a_x, a_y, a_z]
% Column vector t contains temporal coordinates. Column vectors x, y, z and
% a contain orientations in the axis-angle representation.
% Matrix VA is optional. Any data therein is only used for visualization.
% Column vectors v_x, v_y and v_z contain velocity data.
% Matrix A is optional. Column vectors a_x, a_y and a_z contain
% acceleration data.

%% Compress Keys
fprintf('\nCompressing keys...');

[position, orientation] = compressKeys(position, orientation);

%% Validate Keys
fprintf('\nValidating keys...');

validKeys(position, orientation);

%% Visualize Keys
fprintf('\nVisualizing keys...\n');

flag = true;
while flag
    fig = visualize(position, orientation);
    while true
        str = input('    Watch again? Y/n [Y]: ', 's');
        if isempty(str) || strcmp(str, 'Y')
            break;
        elseif strcmp(str, 'n')
            flag = false;
            break;
        end
    end
end

fprintf('\n');

while true
    str = input('Commit animation to file? Y/n [Y]: ', 's');
    if isempty(str) || strcmp(str, 'Y')
        if ishandle(fig)
            close(fig);
        end
        break;
    elseif strcmp(str, 'n')
        warning('Animation not written to file.');
        if ishandle(fig)
            close(fig);
        end
        return;
    end
end

%% Create New MDL File
fprintf('\nCreating MDL file...');

fileName = sprintf('%s.mdl', camName);
fileID = fopen(fileName, 'wt');

%% Write Header
fprintf('\nWriting header...');

header = sprintf([...
    'filedependancy %s NULL.mlk\n'...
    'newmodel %s\n'...
    'setsupermodel %s NULL\n'...
    'classification Character\n'...
    'setanimationscale 1\n'...
    '\n'...
    'beginmodelgeom %s\n'...
    '  bmin -5 -5 -1\n'...
    '  bmax 5 5 10\n'...
    '  radius 7\n'...
    'node dummy %s\n'...
    '  parent NULL\n'...
    '  specular 0.000000 0.000000 0.000000\n'...
    '  shininess 0.000000\n'...
    '  wirecolor 1 1 1\n'...
    'endnode\n'...
    'node dummy camerahook\n'...
    '  parent %s\n'...
    '  position %f %f %f\n'...
    '  orientation %f %f %f %f\n'...
    '  specular 0.000000 0.000000 0.000000\n'...
    '  shininess 0.000000\n'...
    '  wirecolor 1 1 1\n'...
    'endnode\n'...
    'endmodelgeom %s\n'...
    '\n'],...
    camName, camName, camName, camName, camName, camName,...
    position(1, 2), position(1, 3), position(1, 4),...
    orientation(1, 2), orientation(1, 3), orientation(1, 4),...
    orientation(1, 5), camName);
fprintf(fileID, header);

%% Write Animations
fprintf('\nWriting animations...');

animID = 1;
writeAnim(camName, fileID, animID,...
          t(end), position(:, 1:4), orientation(:, 1:5));

%% Write Footer
fprintf('\nWriting footer...');

footer = sprintf('donemodel %s\n', camName);
fprintf(fileID, footer);

%% Close MDL File
fprintf('\nClosing file...');

fclose(fileID);

fprintf('\nDone.\n');

end

