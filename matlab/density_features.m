function res = density_features(rect, pixels, varargin)
% DENSITY_FEATURES   Subjects RECT to a variety of density related features.
%
%  DENSITY_FEATURES(RECT, PAGE, {THRESHOLD})  Runs the 4 element vector RECT
%  passed against 2 different desnsity features, each of which returns a
%  scalar value.  These values along with the feature name are built up as
%  fields in a struct, with one entry for each feature.  These entries are
%  combined in a cell array and returned as RES.
%
%  If THRESHOLD is specified, it should be given as a percentage (between
%  0 and 1), determining the amount of non-background pixels that must be found
%  for the side to be considered significant.  If not specified it defaults to 
%  2 percent.


% CVS INFO %
%%%%%%%%%%%%
% $Id: density_features.m,v 1.1 2003-08-18 15:46:18 scottl Exp $
% 
% REVISION HISTORY:
% $Log: density_features.m,v $
% Revision 1.1  2003-08-18 15:46:18  scottl
% Initial revision.  Merger of 2 previously individualy calculated density
% features.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02;    % default threshold to use if not passed above
bg = 1;             % default value for background pixels
ink_count = 0;      % the # of non background pixels counted
get_names = false;  % determine if we are looking for names only


% first do some argument sanity checking on the arguments passed
error(nargchk(0,3,nargin));

if nargin == 0
    get_names = true;
elseif nargin == 1
    error('can not pass in 1 argument.  Must be 0, 2 or 3');
else
    [r, c] = size(pixels);
    
    if ndims(rect) > 2 | size(rect) ~= 4
        error('RECT passed must have exactly 4 elements');
    elseif rect(1) < 1 | rect(2) < 1 | rect(3) > c | rect(4) > r
        error('RECT passed exceeds PAGE boundaries');
    end
    
    if nargin == 3
        if varargin{1} < 0 | varargin{1} > 1
            error('THRESHOLD passed must be a percentage (between 0 and 1)');
        end
        threshold = varargin{1};
    end
end

res = {};


% feature 1 counts the percentage of non-background pixels over the total
% number of pixels inside the rectangle passed.
res{1}.name  = 'rect_dens';

% feature 2 is similar to 1, but calculates the percentage of non-backgorund
% pixels over the total number of pixels inside the "snapped" subrectangle of
% the rectangle passed.
res{2}.name  = 'sr_dens';


if get_names
    return;
end


% calculate feature 1 value
left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);

for i = top:bottom
    for j = left:right
        if pixels(i, j) ~= bg
            ink_count = ink_count + 1;
        end
    end
end

res{1}.val = ink_count / ((bottom - top + 1) * (right - left + 1));


% now calculate feature 2 value
sr = get_sr(rect, pixels, threshold);
res{2}.val = ink_count / ((sr(4) - sr(2) + 1) * (sr(3) - sr(1) + 1));
