function p = rect_dens_feature(rect, pixels)
% RECT_DENS_FEATURE   Returns the total percentage of non-background pixels
%                     inside the RECT passed.
%
%  P = RECT_DENS_FEATURE(RECT, PAGE)  This feature simply counts all the
%  pixels within the RECT region of PAGE, and returns the percentage of which
%  that are 'ink' i.e. non-background colour.


% CVS INFO %
%%%%%%%%%%%%
% $Id: rect_dens_feature.m,v 1.1 2003-07-23 22:26:17 scottl Exp $
% 
% REVISION HISTORY:
% $Log: rect_dens_feature.m,v $
% Revision 1.1  2003-07-23 22:26:17  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

bg = 1;  % default value for background pixels


% first do some argument sanity checking on the arguments passed
error(nargchk(2,2,nargin));

[r, c] = size(pixels);

if ndims(rect) > 2 | size(rect) ~= 4
    error('RECT passed must have exactly 4 elements');
elseif rect(1) < 1 | rect(2) < 1 | rect(3) > c | rect(4) > r
    error('RECT passed exceeds PAGE boundaries');
end

ink_count = 0;
total_count = 0;

for i = rect(2):rect(4)
    for j = rect(1):rect(3)
        total_count = total_count + 1;
        if pixels(i, j) ~= bg
            ink_count = ink_count + 1;
        end
    end
end

p = ink_count / total_count;
