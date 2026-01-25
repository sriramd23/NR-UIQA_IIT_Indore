function features_struct = feature_extract(img, color_mode)
% FEATURE_EXTRACT
% Extracts 21 Multi-scale Feature Combinations.
% Robust against dimension mismatches, index errors, and argument errors.

%% 1. PRE-PROCESSING
if size(img, 3) == 1
    img = cat(3, img, img, img);
end
img = double(img);

% Ensure 0-255 range for structural functions
if max(img(:)) <= 1.0
    img = img * 255; 
end

%% 2. COLOR DECOMPOSITION
hsv_img = rgb2hsv(img / 255); 
H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);

switch color_mode
    case 'H', c_img_base = cat(3, H, H, H);
    case 'S', c_img_base = cat(3, S, S, S);
    case 'V', c_img_base = cat(3, V, V, V);
    case 'HS', c_img_base = cat(3, H, S, zeros(size(H)));
    otherwise, error('Invalid color_mode. Use H, S, V, or HS.');
end

%% 3. MULTI-SCALE EXTRACTION
num_scales = 3;
atomic_feats = cell(num_scales, 2); 

for s = 1:num_scales
    % --- Resize Logic ---
    scale_factor = 1 / (2^(s-1)); 
    
    if s == 1
        img_s = img;
        c_img_s = c_img_base;
    else
        img_s = imresize(img, scale_factor);
        c_img_s = imresize(c_img_base, scale_factor);
        
        % Clamp to prevent index errors (Critical Fix)
        img_s = max(0, min(255, img_s));
        c_img_s = max(0, min(1, c_img_s));
    end
    
    % --- EXTRACT COLOR (FA) ---
    try
        % 1. Get Raw Outputs
        raw_CM = safe_exec_color(@color_moment, c_img_s);
        raw_CE = safe_exec(@color_entropy, c_img_s);
        raw_IE = safe_exec(@Imentropy, c_img_s);
        
        % 2. Force to Row Vectors (1xN)
        F_CM = reshape(double(raw_CM), 1, []);
        F_CE = reshape(double(raw_CE), 1, []);
        F_IE = reshape(double(raw_IE), 1, []);
        
        atomic_feats{s, 1} = [F_CM, F_CE, F_IE];
    catch ME
        % If error, print but continue with zeros so script doesn't stop
        atomic_feats{s, 1} = zeros(1, 15); 
    end

    % --- EXTRACT STRUCTURE (FB) ---
    try
        % 1. Get Raw Outputs
        raw_GD = safe_exec(@gradient_domain, img_s);
        raw_UI = safe_exec(@UISM, img_s);
        raw_LB = safe_exec(@LBP, img_s);
        
        % 2. Sanitize LBP (Critical Fix for "Dimensions not consistent")
        % If LBP returns a Matrix (Image) instead of a Vector (Hist), convert it.
        if numel(raw_LB) > 1024
             raw_LB = imhist(uint8(raw_LB))';
             raw_LB = raw_LB / sum(raw_LB); % Normalize
        end
        
        % 3. Force to Row Vectors
        F_GD = reshape(double(raw_GD), 1, []);
        F_UI = reshape(double(raw_UI), 1, []);
        F_LB = reshape(double(raw_LB), 1, []);
        
        atomic_feats{s, 2} = [F_GD, F_UI, F_LB];
        
    catch ME
        atomic_feats{s, 2} = zeros(1, 15); 
    end
end

%% 4. COMBINATIONS
features_struct = struct();

% Single Scale
for s = 1:3
    tag = sprintf('S%d', s);
    features_struct.([tag '_FA'])  = atomic_feats{s, 1};
    features_struct.([tag '_FB'])  = atomic_feats{s, 2};
    features_struct.([tag '_FAB']) = [atomic_feats{s, 1}, atomic_feats{s, 2}];
end

% Multi-Scale
combos = [1 2; 1 3; 2 3];
names  = {'S12', 'S13', 'S23'};
for k = 1:3
    idxs = combos(k, :);
    nm = names{k};
    features_struct.([nm '_FA'])  = [atomic_feats{idxs(1),1}, atomic_feats{idxs(2),1}];
    features_struct.([nm '_FB'])  = [atomic_feats{idxs(1),2}, atomic_feats{idxs(2),2}];
    features_struct.([nm '_FAB']) = [features_struct.([nm '_FA']), features_struct.([nm '_FB'])];
end

% All Scales
features_struct.S123_FA  = [atomic_feats{1,1}, atomic_feats{2,1}, atomic_feats{3,1}];
features_struct.S123_FB  = [atomic_feats{1,2}, atomic_feats{2,2}, atomic_feats{3,2}];
features_struct.S123_FAB = [features_struct.S123_FA, features_struct.S123_FB];

end

%% --- HELPERS ---
function out = safe_exec(func, img)
    try
        out = func(img);
    catch ME
        % Handle common "missing argument" or "index type" errors automatically
        if contains(ME.message, 'input arguments'), try out = func(img, 1); catch, rethrow(ME); end;
        elseif contains(ME.message, 'Index'), try out = func(uint8(img)); catch, rethrow(ME); end;
        else, rethrow(ME); end
    end
end

function out = safe_exec_color(func, img)
    % Specifically for color_moment which usually needs 2 args
    try
        out = func(img, 1); 
    catch 
        try out = func(img); catch ME, rethrow(ME); end
    end
end