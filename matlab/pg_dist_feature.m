function [left, top, right, bottom] = pg_dist_feature(rect, pixels)
% PG_DIST_FEATURE   Returns the distance from the rectangle passed to the edge
%                   of the page.
%
%  [L, R, T, B] = PG_DIST_FEATURE(RECT, PAGE)  This feature simply returns a 4
%  element row vector containing the pixel distance to the left, top, right,
%  and bottom edges of the page matrix PAGE, starting from the 4 element
%  column vector RECT passed.


% CVS INFO %
%%%%%%%%%%%%
% $Id: pg_dist_feature.m,v 1.1 2003-07-23 20:30:39 scottl Exp $
% 
% REVISION HISTORY:
% $Log: pg_dist_feature.m,v $
% Revision 1.1  2003-07-23 20:30:39  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% first do some argument sanity checking on the arguments passed
error(nargchk(2,2,nargin));

[r, c] = size(pixels);

if ndims(rect) > 2 | size(rect) ~= 4
    error('RECT passed must have exactly 4 elements');
elseif rect(1) < 0 | rect(2) < 0 | rect(3) > c | rect(4) > r
    error('RECT passed exceeds PAGE boundaries');
end

left = rect(1) - 1;
top = rect(2) - 1;
right = c - rect(3);
bottom = r - rect(4);
