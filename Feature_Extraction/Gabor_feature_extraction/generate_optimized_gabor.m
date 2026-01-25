% ============================================================
% generate_optimized_gabor.m
%
% Folder-mirrored luminance Gabor feature extraction
% (UID / SAUD compatible)
%
% Images  →  .mat files (FGabor: 1×12)
% ============================================================

clc; clear;

% ------------------------------------------------------------
% >>>>>>>>>>>>>>> USER-EDITABLE PATHS <<<<<<<<<<<<<<
% ------------------------------------------------------------

% INPUT DATASET ROOT (images)
% Example:
%   'D:/Datasets/UID/'
%   'D:/Datasets/SAUD/'
input_root  = 'F:\new downloads\Underwater-20251203T082423Z-1-001\Underwater\Datasets\SAUD';

% OUTPUT ROOT (mirrored feature dataset)
% Example:
%   'D:/Datasets/UID_Gabor/'
output_root = 'C:\Users\srira\Downloads\Research_intern_task2\Extracted_Features_of_Datasets_SAUD_Gabor';

% Image extensions to process
valid_ext = {'.png', '.jpg', '.jpeg', '.bmp'};

% ------------------------------------------------------------
% Start processing
% ------------------------------------------------------------

if ~exist(output_root, 'dir')
    mkdir(output_root);
end

fprintf('Starting Gabor feature extraction...\n');
fprintf('Input  : %s\n', input_root);
fprintf('Output : %s\n\n', output_root);

process_folder(input_root, output_root, valid_ext);

fprintf('\nDone. Folder structure mirrored successfully.\n');

% ============================================================
% Recursive folder processor
% ============================================================
function process_folder(src_dir, dst_dir, valid_ext)

    items = dir(src_dir);

    for i = 1:length(items)

        name = items(i).name;

        % Skip system entries
        if strcmp(name, '.') || strcmp(name, '..')
            continue;
        end

        src_path = fullfile(src_dir, name);
        dst_path = fullfile(dst_dir, name);

        if items(i).isdir
            % -----------------------------
            % Directory → recurse
            % -----------------------------
            if ~exist(dst_path, 'dir')
                mkdir(dst_path);
            end
            process_folder(src_path, dst_path, valid_ext);

        else
            % -----------------------------
            % File → image → feature
            % -----------------------------
            [~, fname, ext] = fileparts(name);

            if any(strcmpi(ext, valid_ext))
                try
                    img = imread(src_path);

                    % Extract 12-D luminance Gabor feature
                    FGabor = extract_luminance_gabor_features(img);

                    % Save .mat with same base name
                    save(fullfile(dst_dir, [fname '.mat']), 'FGabor');

                catch ME
                    fprintf('Failed: %s\n', src_path);
                    fprintf('Reason: %s\n', ME.message);
                end
            end
        end
    end
end
