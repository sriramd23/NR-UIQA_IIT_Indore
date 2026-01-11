source_root = 'F:\new downloads\Underwater-20251203T082423Z-1-001\Underwater\Datasets';

output_root = 'C:\Users\srira\Downloads\Research_intern_task2\Extracted_Features_of_Datasets';

all_images = dir(fullfile(source_root, '**', '*.png'));

if isempty(all_images)
    error('No images found! Check your source path or file extension.');
end

count = 0;

% 2. Loop through every single image found
for i = 1:length(all_images)
    
    % Get basic info for the current image
    current_filename = all_images(i).name;
    current_folder   = all_images(i).folder;
    full_source_path = fullfile(current_folder, current_filename);
    
    relative_path = extractAfter(current_folder, length(source_root));
    
    % If relative_path starts with a slash, remove it for cleanliness
    if startsWith(relative_path, filesep)
        relative_path = relative_path(2:end);
    end
    
    % Combine your Output Root with the calculated subfolder structure
    target_folder = fullfile(output_root, relative_path);
    
    % Create this specific subfolder if it doesn't exist yet
    if ~exist(target_folder, 'dir')
        mkdir(target_folder);
    end
    
    try
        img = imread(full_source_path);
        features = feature_extract(img);

        [~, name_body, ~] = fileparts(current_filename);
        
        mat_filename = [name_body, '.mat'];
        
        full_dest_path = fullfile(target_folder, mat_filename);
        
        % Save variable 'features' into the file
        save(full_dest_path, 'features', '-v7');
        
        count = count + 1;
        
        % Progress indicator every 10 images
        if mod(count, 10) == 0
            fprintf('Processed %d images...\n', count);
        end
        
    catch ME
        fprintf('Error processing %s: %s\n', current_filename, ME.message);
    end
end

fprintf('\nSuccess! Processed %d images.\n', count);
fprintf('Your extracted dataset features is at: %s\n', output_root);