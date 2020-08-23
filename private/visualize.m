function fig = visualize(position, orientation)
%% Visualize
% Visualizes the position and orientation keys.
%% Parse Position Key
t_p     = position(:, 1);
t_min_p = t_p(1);
t_max_p = t_p(end);

x = position(:, 2);
y = position(:, 3);
z = position(:, 4);

% The number of columns.
m_p = size(position, 2);

% Parse velocity data, if any.
if 7 <= m_p
    velocity_p = true;
    v_x = position(:, 5);
    v_y = position(:, 6);
    v_z = position(:, 7);
else
    velocity_p = false;
end

% Parse acceleration data, if any.
if 10 <= m_p
    acceleration_p = true;
    a_x = position(:, 8);
    a_y = position(:, 9);
    a_z = position(:, 10);
else
    acceleration_p = false;
end

%% Parse Orientation Key
t_r     = orientation(:, 1);
t_min_r = t_r(1);
t_max_r = t_r(end);

% The number of samples
n_r = numel(t_r);

% The number of columns.
m_r = size(orientation, 2);

quat = axang2quat(orientation(:, 2:5));
rotm = axang2rotm(orientation(:, 2:5));
r = -reshape(rotm(:, 3, :), [3, n_r])';

% Parse velocity data, if any.
if 8 <= m_r
    velocity_r = true;
    v_r = orientation(:, 6:8);
else
    velocity_r = false;
end

% Parse acceleration data, if any.
if 11 <= m_r
    acceleration_r = true;
    a_r = orientation(:, 9:11);
else
    acceleration_r = false;
end

%% Display Initial Figure
if ishandle(1)
    close(1);
end
fig = figure(1);

% Set axis limits.
x_min = min(x);
x_max = max(x);
y_min = min(y);
y_max = max(y);
z_min = min(z);
z_max = max(z);

if velocity_p
    x_min = min([x_min; x + v_x]);
    x_max = max([x_max; x + v_x]);
    y_min = min([y_min; y + v_y]);
    y_max = max([y_max; y + v_y]);
    z_min = min([z_min; z + v_z]);
    z_max = max([z_max; z + v_z]);
end

if acceleration_p
    x_min = min([x_min; x + a_x]);
    x_max = max([x_max; x + a_x]);
    y_min = min([y_min; y + a_y]);
    y_max = max([y_max; y + a_y]);
    z_min = min([z_min; z + a_z]);
    z_max = max([z_max; z + a_z]);
end

% Find the time indices that the two keys have in common.
%i = ismember(position(:, 1), orientation(:, 1));
%j = ismember(orientation(:, 1), position(:, 1));

if velocity_r
    %x_min = min([x_min; x(i) + r(j, 1) + v_r(j, 1)]);
    %x_max = max([x_max; x(i) + r(j, 1) + v_r(j, 1)]);
    %y_min = min([y_min; y(i) + r(j, 2) + v_r(j, 2)]);
    %y_max = max([y_max; y(i) + r(j, 2) + v_r(j, 2)]);
    %z_min = min([z_min; z(i) + r(j, 3) + v_r(j, 3)]);
    %z_max = max([z_max; z(i) + r(j, 3) + v_r(j, 3)]);
    
    x_min = min([x_min; min(x) + min(r(:, 1) + v_r(:, 1))]);
    x_max = max([x_max; max(x) + max(r(:, 1) + v_r(:, 1))]);
    y_min = min([y_min; min(y) + min(r(:, 2) + v_r(:, 2))]);
    y_max = max([y_max; max(y) + max(r(:, 2) + v_r(:, 2))]);
    z_min = min([z_min; min(z) + min(r(:, 3) + v_r(:, 3))]);
    z_max = max([z_max; max(z) + max(r(:, 3) + v_r(:, 3))]);
end

if acceleration_r
    %x_min = min([x_min; x(i) + r(j, 1) + a_r(j, 1)]);
    %x_max = max([x_max; x(i) + r(j, 1) + a_r(j, 1)]);
    %y_min = min([y_min; y(i) + r(j, 2) + a_r(j, 2)]);
    %y_max = max([y_max; y(i) + r(j, 2) + a_r(j, 2)]);
    %z_min = min([z_min; z(i) + r(j, 3) + a_r(j, 3)]);
    %z_max = max([z_max; z(i) + r(j, 3) + a_r(j, 3)]);
    
    x_min = min([x_min; min(x) + min(r(:, 1) + a_r(:, 1))]);
    x_max = max([x_max; max(x) + max(r(:, 1) + a_r(:, 1))]);
    y_min = min([y_min; min(y) + min(r(:, 2) + a_r(:, 2))]);
    y_max = max([y_max; max(y) + max(r(:, 2) + a_r(:, 2))]);
    z_min = min([z_min; min(z) + min(r(:, 3) + a_r(:, 3))]);
    z_max = max([z_max; max(z) + max(r(:, 3) + a_r(:, 3))]);
end

x_min = x_min - 1;
x_max = x_max + 1;
y_min = y_min - 1;
y_max = y_max + 1;
z_min = z_min - 1;
z_max = z_max + 1;

axis([x_min, x_max,...
      y_min, y_max,...
      z_min, z_max]);

t_min = min([t_min_p, t_min_r]);
t_max = max([t_max_p, t_max_r]);

hold on;

x_now = x(1);
y_now = y(1);
z_now = z(1);

% Plot initial position.
h_l = plot3(x_now,...
            y_now,...
            z_now,...
            'b');

% Encircle initial position.
h_s = scatter3(x_now, y_now, z_now, 'b');

r_now = r(1, :);

% Plot initial orientation
h_r = quiver3(   x_now,    y_now,    z_now,...
              r_now(1), r_now(2), r_now(3), 'b');

if velocity_p
    if t_min < t_min_p
        v_x_now = 0;
        v_y_now = 0;
        v_z_now = 0;
    else
        v_x_now = v_x(1);
        v_y_now = v_y(1);
        v_z_now = v_z(1);
    end
    
    % Plot initial velocity vector.
    h_v_p = quiver3(  x_now,   y_now,   z_now,...
                    v_x_now, v_y_now, v_z_now, 'g');
end

if velocity_r
    if t_min < t_min_r
        v_r_now = zeros([1, 3]);
    else
        v_r_now = v_r(1, :);
    end
    
    % Plot initial orientation velocity vector.
    h_v_r = quiver3(x_now+r_now(1), y_now+r_now(2), z_now+r_now(3),...
                        v_r_now(1),     v_r_now(2),     v_r_now(3), 'g');
end

if acceleration_p
    if t_min < t_min_p
        a_x_now = 0;
        a_y_now = 0;
        a_z_now = 0;
    else
        a_x_now = a_x(1);
        a_y_now = a_y(1);
        a_z_now = a_z(1);
    end
    
    % Plot initial acceleration vector.
    h_a_p = quiver3(  x_now,   y_now,   z_now,...
                    a_x_now, a_y_now, a_z_now, 'r');
end

if acceleration_r
    if t_min < t_min_r
        a_r_now = zeros([1, 3]);
    else
        a_r_now = a_r(1, :);
    end
    
    % Plot initial orientation acceleration vector.
    h_a_r = quiver3(x_now+r_now(1), y_now+r_now(2), z_now+r_now(3),...
                        a_r_now(1),     a_r_now(2),     a_r_now(3), 'r');
end

% Display labels.
h_t = title(sprintf('t = %.1f', t_min));
xlabel('x');
ylabel('y');
zlabel('z');

hold off;

drawnow;

pause(1);

%% Display Intermediate Figures
finalized_p = false;
finalized_r = false;
t_prv = t_min;
tic;
t_now = t_min + toc;
while t_now < t_max
    
    % Update position.
    if t_now < t_min_p
        % Do nothing.
    elseif t_max_p <= t_now
        
        if finalized_p
            % Do nothing.
        else
            finalized_p = true;
            
            x_now = x(end);
            y_now = y(end);
            z_now = z(end);
        
            % Plot position path in interval [t_prv, t_max_p].
            i = t_prv < t_p;
            set(h_l, {'XData', 'YData', 'ZData'},...
                     {[get(h_l, 'XData'), x(i)'],...
                      [get(h_l, 'YData'), y(i)'],...
                      [get(h_l, 'ZData'), z(i)']});
    
            % Encircle final position.
            set(h_s, {'XData', 'YData', 'ZData'},...
                     { x(end),  y(end),  z(end)});
    
            if velocity_p
                % Delete velocity vector.
                delete(h_v_p);
            end
            
            if acceleration_p
                % Delete acceleration vector.
                delete(h_a_p);
            end
        end
    else
        % Find latest sample i.
        d = t_now - t_p;
        [~, i] = min(abs(d));
        if d(i) < 0
            % then t_min_p <= t_p(i-1) < t_now < t_p(i).
            i = i-1;
        else
            % then t_p(i) <= t_now < t_p(i+1) <= t_max_p.
        end
        
        % Latest position sample.
        a = position(i, :);
        % Next position sample.
        b = position(i+1, :);
        % Interpolate current position.
        c = a + ((t_now - t_p(i)) / (t_p(i+1) - t_p(i))) * (b - a);
        
        x_now = c(2);
        y_now = c(3);
        z_now = c(4);
        
        % Plot position path in interval [t_prv, t_now].
        i = (t_prv < t_p) & (t_p < t_now);
        set(h_l, {'XData', 'YData', 'ZData'},...
                 {[get(h_l, 'XData'), x(i)', x_now],...
                  [get(h_l, 'YData'), y(i)', y_now],...
                  [get(h_l, 'ZData'), z(i)', z_now]});
    
        % Encircle current position.
        set(h_s, {'XData', 'YData', 'ZData'},...
                 {  x_now,   y_now,   z_now});
    
        if velocity_p
            v_x_now = a(5);
            v_y_now = a(6);
            v_z_now = a(7);
            
            % Plot velocity vector.
            set(h_v_p,...
                {'XData', 'YData', 'ZData',...
                 'UData', 'VData', 'WData'},...
                {  x_now,   y_now,   z_now,...
                 v_x_now, v_y_now, v_z_now});
        end
    
        if acceleration_p
            a_x_now = a(8);
            a_y_now = a(9);
            a_z_now = a(10);
            
            % Plot acceleration vector.
            set(h_a_p,...
                {'XData', 'YData', 'ZData',...
                 'UData', 'VData', 'WData'},...
                {  x_now,   y_now,   z_now,...
                 a_x_now, a_y_now, a_z_now});
        end
    end
    
    % Update orientation.
    if t_now < t_min_r
        % Plot initial orientation vector.
        set(h_r,...
            {'XData', 'YData', 'ZData',...
             'UData', 'VData', 'WData'},...
            {  x_now,   y_now,   z_now,...
             r(1, 1), r(1, 2), r(1, 3)});
         
    elseif t_max_r <= t_now
        % Plot final orientation vector.
        set(h_r,...
            {  'XData',   'YData',   'ZData',...
               'UData',   'VData',   'WData'},...
            {    x_now,     y_now,     z_now,...
             r(end, 1), r(end, 2), r(end, 3)});
        
        if finalized_r
            % Do nothing.
        else
            finalized_r = true;
            
            if velocity_r
                % Delete orientation velocity vector.
                delete(h_v_r);
            end
            
            if acceleration_r
                % Delete orientation acceleration vector.
                delete(h_a_r);
            end
        end
    else
        % Find latest sample i.
        d = t_now - t_r;
        [~, i] = min(abs(d));
        if d(i) < 0
            % then t_min_r <= t_r(i-1) < t_now < t_r(i).
            i = i-1;
        else
            % then t_r(i) <= t_now < t_r(i+1) <= t_max_r.
        end
        
        % Latest orientation sample.
        a = quat(i, :);
        % Next orientation sample.
        b = quat(i+1, :);
        % Interpolate current orientation.
        C = quat2rotm(quatinterp(a, b,...
                                 (t_now - t_r(i))/(t_r(i+1) - t_r(i)),...
                                 'slerp'));
        
        r_now = -C(:, 3)';
        
        % Plot orientation vector.
        set(h_r,...
            { 'XData',  'YData',  'ZData',...
              'UData',  'VData',  'WData'},...
            {   x_now,    y_now,   z_now,...
             r_now(1), r_now(2), r_now(3)});
        
        if velocity_r
            v_r_now = v_r(i, :);
            
            % Plot orientation velocity vector.
            set(h_v_r,...
                {       'XData',        'YData',        'ZData',...
                        'UData',        'VData',        'WData'},...
                {x_now+r_now(1), y_now+r_now(2), z_now+r_now(3),...
                     v_r_now(1),     v_r_now(2),     v_r_now(3)});
        end
        
        if acceleration_r
            a_r_now = a_r(i, :);
            
            % Plot orientation acceleration vector.
            set(h_a_r,...
                {       'XData',        'YData',        'ZData',...
                        'UData',        'VData',        'WData'},...
                {x_now+r_now(1), y_now+r_now(2), z_now+r_now(3),...
                     a_r_now(1),     a_r_now(2),     a_r_now(3)});
        end
    end
    
    % Display title.
    set(h_t,...
        'String',...
        sprintf('t = %.1f', t_now));
    
    drawnow;
    
    % Update time.
    t_prv = t_now;
    t_now = t_min + toc;
end

%% Display Final Figure

if t_max_p == t_max
    % Plot position path in interval [t_prv, t_max].
    i = t_prv < t_p;
    set(h_l, {'XData', 'YData', 'ZData'},...
             {[get(h_l, 'XData'), x(i)'],...
              [get(h_l, 'YData'), y(i)'],...
              [get(h_l, 'ZData'), z(i)']});
    
    % Encircle final position.
    set(h_s, {'XData', 'YData', 'ZData'},...
             { x(end),  y(end),  z(end)});
    
    if velocity_p
        % Plot final velocity vector.
        set(h_v_p,...
            { 'XData',  'YData',  'ZData',...
              'UData',  'VData',  'WData'},...
            {  x(end),   y(end),   z(end),...
             v_x(end), v_y(end), v_z(end)});
    end
    
    if acceleration_p
        % Plot final acceleration vector.
        set(h_a_p,...
            { 'XData',  'YData',  'ZData',...
              'UData',  'VData',  'WData'},...
            {  x(end),   y(end),   z(end),...
             a_x(end), a_y(end), a_z(end)});
    end
end

% Plot final orientation vector.
set(h_r,...
    {  'XData',   'YData',   'ZData',...
       'UData',   'VData',   'WData'},...
    {   x(end),    y(end),    z(end),...
     r(end, 1), r(end, 2), r(end, 3)});

if t_max_r == t_max
    if velocity_r
        % Plot final orientation velocity vector.
        set(h_v_r,...
            {         'XData',          'YData',          'ZData',...
                      'UData',          'VData',          'WData'},...
            {x(end)+r(end, 1), y(end)+r(end, 2), z(end)+r(end, 3),...
                  v_r(end, 1),      v_r(end, 2),      v_r(end, 3)});
    end
    
    if acceleration_r
        % Plot final orientation acceleration vector.
        set(h_a_r,...
            {         'XData',          'YData',          'ZData',...
                      'UData',          'VData',          'WData'},...
            {x(end)+r(end, 1), y(end)+r(end, 2), z(end)+r(end, 3),...
                  a_r(end, 1),      a_r(end, 2),      a_r(end, 3)});
    end
end

% Display title.
set(h_t,...
    'String',...
    sprintf('t = %.1f', t_max));

drawnow;

pause(1);

end

