function m = xycut(img_file, varargin)
% XYCUT    Decompose the image passed into a set of subrectangle segments
%          using the top-down X-Y cut page segmentation algorithm.
%
%   M = XYCUT(IMG_FILE, {H_THRESH, V_THRESH})  splits the page specified by
%   IMG_FILE into segments recursively by making cuts into the most prominent
%   valley in the horizontal and vertical directions at each step.  This
%   process bottoms out when the valleys are less than H_THRESH and V_THRESH
%   pixels in length.
%
%   The nx4 matrix M returned lists the left,top,bottom,right co-ordinates of
%   each of the n segments created.
%
%   H_THRESH and V_THRESH are optional, and if left unspecified H_THRESH
%   defaults to: 40 and V_THRESH defaults to: 20
%
%   If there is a problem at any point, an error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: xycut.m,v 1.4 2004-04-26 22:53:22 klaven Exp $
%
% REVISION HISTORY:
% $Log: xycut.m,v $
% Revision 1.4  2004-04-26 22:53:22  klaven
% Changed xycut to include wst.  The wst is the White Space Threshold - the minimum fraction of black pixels that still counts as whitespace.  Setting this to 0 leaves the algorithm the same as before.
%
% Revision 1.3  2004/04/22 16:51:04  klaven
% Assorted changes made while testing lr and knn on larger samples
%
% Revision 1.2  2003/08/12 22:21:42  scottl
% Changed default thresholds to 30 and 30.
%
% Revision 1.1  2003/08/01 22:01:36  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

ht = 40;  % default horizontal threshold (if not passed above)
vt = 20;  % default vertical threshold (if not passed above)
wst = 0;  % minimum percent ink in whitespace to count as valley


% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));

if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
    error('IMG_FILE must contain a single string.');
end

if nargin >= 2
    ht = varargin{1};
    if nargin == 3
        vt = varargin{2};
    end
end

% attempt open the file and read in its pixel data
p = imread(img_file);

% determine the initial page bounding box co-ords
x1 = 1;
y1 = 1;
x2 = size(p,2);
y2 = size(p,1);

% recursively segment the bounding box to create the list of segments
m = segment(p, x1, y1, x2, y2, ht, vt, wst);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = segment(p, x1, y1, x2, y2, ht, vt, wst)
% SEGMENT  Recursive subfunction that segments the rectangle passed into
%          smaller pieces using the XY cut algorithm.

% start by determining the sum of all non-background pixels in the horizontal
% and vertical directions within the co-ord box passed -- note we must use 1-
% pixel value since background pixels are 1
hmeans = mean(1 - p(y1:y2, x1:x2));
vmeans = mean(1 - p(y1:y2, x1:x2), 2);

% determine the longest background valley (sum value = 0) run in both
% directions
[hrunlength, hrunpos] = long_valley(hmeans, wst);
[vrunlength, vrunpos] = long_valley(vmeans, wst);

if vrunlength > vt & vrunlength >= hrunlength
    % make a horizontal cut along the vertical midpoint
    res = [segment(p, x1, y1, x2, (y1 + vrunpos), ht, vt, wst); ...
           segment(p, x1, (y1 + vrunpos), x2, y2, ht, vt, wst)];

elseif hrunlength > ht & hrunlength >= vrunlength
    % make a vertical cut along the horizontal midpoint
    res = [segment(p, x1, y1, (x1 + hrunpos), y2, ht, vt, wst); ...
           segment(p, (x1 + hrunpos), y1, x2, y2, ht, vt, wst)];
else
    % non-recursive case, don't split anything
    res = [x1, y1, x2, y2];
end


function [longlength, mid] = long_valley(means, wst)
% LONG_VALLEY  Subfunction that determines the length and midpoint position of
%              the longest background valley (meanss value <=wst) run in the 
%              vector passed.  If the vector is all non-zero, a length of 0 is
%              returned and the mid is undefiend (NaN).
% wst: White Space Threshold (fraction of ink pixels considered whitespace)

s = 1;
e = length(means);
currlength = 0;
longlength = 0;
mid = nan;

% strip the leading and trailing 0 runs from sums (since we want a full valley
% for our run count).
while (means(s) <= wst) & (s < e)
    s = s + 1;
end
while (means(e) <= wst) & (s < e)
    e = e - 1;
end

if s >= e
    return;
end

for i = s:e

    if means(i) <= wst
        currlength = currlength + 1;
        if currlength > longlength
            longlength = currlength;
            mid = i - floor(longlength / 2);
        end
    else
        currlength = 0;
    end
end
