function generate_optimized()
    % CONFIGURATION
    dataset_path = 'F:\new downloads\Underwater-20251203T082423Z-1-001\Underwater\Datasets\SAUD';
    output_root  = 'C:\Users\srira\Downloads\Research_intern_task2\Extracted_Features_of_Datasets_SAUD_AllcomboHSV';
    
    color_modes = {'H', 'S', 'V', 'HS'};

    % 1. Find Images
    fprintf('Scanning for images...\n');
    image_files = dir(fullfile(dataset_path, '**', '*.*'));
    valid_exts = {'.png', '.jpg', '.jpeg', '.bmp', '.tif', '.tiff'};
    
    all_names = {image_files.name};
    [~, ~, exts] = cellfun(@fileparts, all_names, 'UniformOutput', false);
    valid_mask = ismember(lower(exts), valid_exts);
    image_files = image_files(valid_mask);
    num_images = length(image_files);

    if isempty(image_files)
        error('No images found in %s', dataset_path);
    end
    fprintf('Found %d images. Starting parallel extraction...\n', num_images);

    % 2. Setup Progress Bar & Data Queue
    if isempty(gcp('nocreate')), parpool; end % Start parallel pool
    
    data_queue = parallel.pool.DataQueue;
    h_wait = waitbar(0, 'Starting processing...', 'Name', 'Feature Extraction Progress');
    
    % Listener: Updates the bar whenever a worker sends data
    afterEach(data_queue, @(count) update_progressbar(count, num_images, h_wait));

    % 3. Parallel Processing Loop
    parfor i = 1:num_images
        file_info = image_files(i);
        filename = file_info.name;
        source_folder = file_info.folder;
        full_source_path = fullfile(source_folder, filename);
        
        try
            % A. Read & Standardize
            img = imread(full_source_path);
            if size(img, 3) == 1, img = cat(3, img, img, img); end
            img = double(img);
            if max(img(:)) <= 1.0, img = img * 255; end
            
            % B. Compute Structural Features (Cached ONCE)
            struct_feats_cache = compute_structure_scales(img);

            % C. Loop Color Modes
            for m = 1:length(color_modes)
                mode = color_modes{m};
                
                % Compute Color Features
                color_feats_scales = compute_color_scales(img, mode);
                
                % Combine
                feats_struct = combine_features(color_feats_scales, struct_feats_cache);
                
                % Save
                rel_path = erase(source_folder, dataset_path);
                if startsWith(rel_path, filesep), rel_path = rel_path(2:end); end
                
                f_names = fieldnames(feats_struct);
                for k = 1:numel(f_names)
                    config_name = f_names{k};
                    data_mat = feats_struct.(config_name);
                    
                    save_dir = fullfile(output_root, mode, config_name, rel_path);
                    if ~exist(save_dir, 'dir')
                        try mkdir(save_dir); catch; end 
                    end
                    
                    [~, fname_no_ext, ~] = fileparts(filename);
                    save_name = fullfile(save_dir, [fname_no_ext '.mat']);
                    
                    par_save(save_name, data_mat);
                end
            end
            
        catch ME
            fprintf('ERROR in %s: %s\n', filename, ME.message);
        end
        
        % Send signal to update progress bar
        send(data_queue, i);
    end
    
    delete(h_wait);
    fprintf('Done! All processing complete.\n');
end

%% --- HELPER FUNCTIONS ---

function update_progressbar(count, total, h_wait)
    % Updates the visual waitbar
    progress = count / total;
    waitbar(progress, h_wait, sprintf('Processed %d of %d images (%.1f%%)', count, total, progress*100));
end

function par_save(fname, feats_mat)
    save(fname, 'feats_mat');
end

function atomic_S = compute_structure_scales(img)
    atomic_S = cell(3, 1);
    for s = 1:3
        scale_factor = 1 / (2^(s-1));
        if s == 1
            img_s = img;
        else
            img_s = imresize(img, scale_factor);
            img_s = max(0, min(255, img_s)); 
        end
        
        F_GD = safe_exec(@gradient_domain, img_s);
        F_UI = safe_exec(@UISM, img_s);
        F_LB = safe_exec(@LBP, img_s);
        
        if numel(F_LB) > 1024
             F_LB = imhist(uint8(F_LB))';
             F_LB = F_LB / sum(F_LB);
        end
        
        atomic_S{s} = [reshape(double(F_GD),1,[]) , reshape(double(F_UI),1,[]) , reshape(double(F_LB),1,[])];
    end
end

function atomic_C = compute_color_scales(img, mode)
    atomic_C = cell(3, 1);
    hsv_img = rgb2hsv(img / 255);
    H = hsv_img(:,:,1); S = hsv_img(:,:,2); V = hsv_img(:,:,3);
    
    switch mode
        case 'H', c_base = cat(3, H, H, H);
        case 'S', c_base = cat(3, S, S, S);
        case 'V', c_base = cat(3, V, V, V);
        case 'HS', c_base = cat(3, H, S, zeros(size(H)));
    end
    
    for s = 1:3
        scale_factor = 1 / (2^(s-1));
        if s == 1
            c_s = c_base;
        else
            c_s = imresize(c_base, scale_factor);
            c_s = max(0, min(1, c_s)); 
        end
        
        try
            try F_CM = color_moment(c_s, 1); catch, F_CM = color_moment(c_s); end
        catch
            F_CM = zeros(1,9);
        end
        
        F_CE = safe_exec(@color_entropy, c_s);
        F_IE = safe_exec(@Imentropy, c_s);
        
        atomic_C{s} = [reshape(double(F_CM),1,[]) , reshape(double(F_CE),1,[]) , reshape(double(F_IE),1,[])];
    end
end

function feats = combine_features(C, S)
    feats = struct();
    for s = 1:3
        tag = sprintf('S%d', s);
        feats.([tag '_FA'])  = C{s};
        feats.([tag '_FB'])  = S{s};
        feats.([tag '_FAB']) = [C{s}, S{s}];
    end
    combos = [1 2; 1 3; 2 3];
    names = {'S12', 'S13', 'S23'};
    for k = 1:3
        idx = combos(k,:);
        nm = names{k};
        feats.([nm '_FA'])  = [C{idx(1)}, C{idx(2)}];
        feats.([nm '_FB'])  = [S{idx(1)}, S{idx(2)}];
        feats.([nm '_FAB']) = [feats.([nm '_FA']), feats.([nm '_FB'])];
    end
    feats.S123_FA  = [C{1}, C{2}, C{3}];
    feats.S123_FB  = [S{1}, S{2}, S{3}];
    feats.S123_FAB = [feats.S123_FA, feats.S123_FB];
end

function out = safe_exec(func, img)
    try
        out = func(img);
    catch ME
        if contains(ME.message, 'input arguments'), try out = func(img, 1); catch, out=0; end;
        elseif contains(ME.message, 'Index'), try out = func(uint8(img)); catch, out=0; end;
        else, out=0; end
    end
end