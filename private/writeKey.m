function writeKey(fileID, key)
%% Write Key
% This function writes a key to an MDL file for use in _Star Wars(R):
% Knights of the Old Republic(TM)_ (_KotOR_).

n = size(key, 1);
m = size(key, 2);

for i=1:n
    fprintf(fileID, '        ');
    for j=1:m
        fprintf(fileID, '%f', key(i, j));
        if j~=m
            fprintf(fileID, ' ');
        else
            fprintf(fileID, '\n');
        end
    end
end

end

