function m = seg1(img_file, varargin)
% SEG1    Decompose the image passed into a set of subrectangle segments
%         using Sam's suggested algorithm.
%
%   M = SEG1(IMG_FILE, {H_THRESH, V_THRESH})  splits the page specified by
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
% $Id: seg1.m,v 1.1 2004-06-19 00:27:28 klaven Exp $
%
% REVISION HISTORY:
% $Log: seg1.m,v $
% Revision 1.1  2004-06-19 00:27:28  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.1  2004/04/26 22:54:03  klaven
% Added seg1.m, an experiment at a different method of segmentation.  This file will be renamed if the experiment works well.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

ht = 1;  % default horizontal threshold (if not passed above)
vt = 1;  % default vertical threshold (if not passed above)
wst = 0.0001; % default whitespace threshold

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
m = hsegment(p, x1, y1, x2, y2, ht, vt, wst);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = hsegment(p, x1, y1, x2, y2, ht, vt, wsthreshold)
% SEGMENT  Recursive subfunction that segments the rectangle passed into
%          smaller pieces using the XY cut algorithm.

% start by determining the sum of all non-background pixels in the horizontal
% and vertical directions within the co-ord box passed -- note we must use 1-
% pixel value since background pixels are 1
%hsums = sum(1 - p(y1:y2, x1:x2));
vavgs = mean(1 - p(y1:y2, x1:x2), 2);

% determine the longest background valley (sum value = 0) run in both
% directions
%[hrunlength, hrunpos] = first_valley(hsums,ht);
[vrunlength, vrunpos] = first_valley(vavgs,vt,wsthreshold);
fprintf('Valley length %i middle %i\n', vrunlength, vrunpos);

if vrunlength >= vt
    % make a horizontal cut along the vertical midpoint
%    res = [vsegment(p, x1, y1, x2, (y1 + vrunpos), ht, vt, wsthreshold); ...
%            hsegment(p, x1, (y1 + vrunpos), x2, y2, ht, vt, wsthreshold)];
    res = [[x1,y1,x2,(y1+vrunpos)]; ...
           hsegment(p,x1, (y1+vrunpos), x2, y2, ht, vt, wsthreshold)];
else
    % non-recursive case, don't split anything
%    res = vsegment(p,x1,y1,x2,y2,ht,vt, wsthreshold);
    res = [x1, y1, x2, y2];
end


function res=vsegment(p, x1, y1, x2, y2, vt, ht,wsthreshold)
havgs = mean(1 - p(y1:y2, x1:x2));
[hrunlength, hrunpos] = first_valley(havgs,ht,wsthreshold);
if hrunlength > ht
    % make a vertical cut along the horizontal midpoint
    res = [vsegment(p, x1, y1, (x1 + hrunpos), y2, ht, vt, wsthreshold); ...
           vsegment(p, (x1 + hrunpos), y1, x2, y2, ht, vt, wsthreshold)];
else
    % non-recursive case, don't split anything
    res = [x1, y1, x2, y2];
end

function [longlength, mid] = first_valley(avgs,minlen,wsthreshold)
% LONG_VALLEY  Subfunction that determines the length and midpoint position of
%              the longest background valley (sums value =0) run in the vector
%              passed.  If the vector is all non-zero, a length of 0 is
%              returned and the mid is undefiend (NaN).

s = 1;
e = length(avgs);
currlength = 0;
longlength = 0;
mid = nan;

% strip the leading and trailing 0 runs from sums (since we want a full valley
% for our run count).
while ((s < e) & (avgs(s) <= wsthreshold))
    s = s + 1;
end
while ((s < e) & (avgs(e) <= wsthreshold))
    e = e - 1;
end

if s >= e
    return;
end

i = s;
while (((longlength < minlen) | (currlength > 0)) & (i <= e))
    if avgs(i) <= wsthreshold
        currlength = currlength + 1;
        if currlength >= minlen
            longlength = currlength;
            mid = i - floor(longlength / 2);
        end
    else
        currlength = 0;
    end
    i = i+1;
end






