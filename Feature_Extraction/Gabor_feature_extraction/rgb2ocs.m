function varargout = rgb2ocs(img)
% RGB → Opponent Color Space
% Supports both:
%   O3 = rgb2ocs(img)
%   [O1, O2, O3] = rgb2ocs(img)

img = double(img);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

O1 = (R - G) / sqrt(2);
O2 = (R + G - 2*B) / sqrt(6);
O3 = (R + G + B) / sqrt(3);

if nargout == 1
    varargout{1} = O3;
elseif nargout == 3
    varargout{1} = O1;
    varargout{2} = O2;
    varargout{3} = O3;
else
    error('rgb2ocs: invalid number of output arguments');
end
end
