function m = dist_img(img_file, varargin)
% DIST_IMG    Decompose the image passed into a set of subrectangle segments
%             using the bottom-up distance imaging method.
%
%   M = DIST_IMG(IMG_FILE, {})  splits the page specified by
%   IMG_FILE into segments.
%
%   The nx4 matrix M returned lists the left,top,bottom,right co-ordinates of
%   each of the n segments created.
%
%   If there is a problem at any point, an error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: dist_img_red.m,v 1.1 2004-04-22 16:56:44 klaven Exp $
%
% REVISION HISTORY:
% $Log: dist_img_red.m,v $
% Revision 1.1  2004-04-22 16:56:44  klaven
% Added the distance-image files that I worked on a few months ago.  These files are not currently used, but they should be in the repository somewhere.
%
% Revision 1.1  2003/08/01 22:01:36  kevinl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

ht = 1;  % default horizontal threshold (if not passed above)
vt = 1;  % default vertical threshold (if not passed above)

BLOCK_SIZE = 5;
XDIST = 1; YDIST = 8;
DIST_THRESHOLD = 15;
%VALLEY_PCT = 0.1;

% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));

if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
    error('IMG_FILE must contain a single string.');
end

%if nargin >= 2
%    ht = varargin{1};
%    if nargin == 3
%        vt = varargin{2};
%    end
%end

% attempt open the file and read in its pixel data
p = imread(img_file);

% determine the page bounding box co-ords
x1 = 1;
y1 = 1;
x2 = size(p,2);
y2 = size(p,1);

m = floor(y2 / BLOCK_SIZE);
n = floor(x2 / BLOCK_SIZE);

p = 1-p;

p2 = zeros(m,n);
for i = 1:m-1; for j = 1:n-1;
    p2(i,j) = any(any(p(1+(BLOCK_SIZE*i):1+(BLOCK_SIZE*(i+1)),1+(BLOCK_SIZE*j):1+(BLOCK_SIZE*(j+1)))));
end; end;


%[i,j] = find(p < 0.5);
%p2(floor(i / BLOCK_SIZE), floor(j / BLOCK_SIZE)) = 0;

p2 = 1-p2;

%imagesc(p2,[0,1]); colormap(gray);

p = p2;
[y2,x2] = size(p);

% Threshold the pixels

A = zeros(size(p));
A(p >= 0.5) = 9999;

%for i = y1:y2
%    for j = x1:x2
%        if p(i,j) < 0.5
%            A(i,j) = 0;
%        else
%            A(i,j) = 9999;
%        end
%    end
%end

% Compute the distance image

for i = y1+1:y2
    A(i,1) = min([A(i,1),A(i-1,1)+YDIST]);
    A(y2-i+1,1) = min([A(y2-i+1,1),A(y2-i+2,1)+YDIST]);
end

for j = x1+1:x2
    A(1,j) = min([A(1,j),A(1,j-1)+XDIST]);
    A(1,x2-j+1) = min([A(1,x2-j+1),A(1,x2-j+2)+XDIST]);
end

for i = y1+1:y2
    for j = x1+1:x2
        A(i,j) = min([A(i,j),A(i-1,j)+YDIST,A(i,j-1)+XDIST]);
        A(y2-i+1,x2-j+1) = min([A(y2-i+1,x2-j+1),A(y2-i+2,x2-j+1)+YDIST,A(y2-i+1,x2-j+2)+XDIST]);
    end
end

% Threshold the distance image

p = zeros(size(A));
p(A >= DIST_THRESHOLD) = 1;

%for i = y1:y2
%    for j = x1:x2
%        if (A(i,j) < DIST_THRESHOLD)
%            p(i,j) = 0;
%        else
%            p(i,j) = 1;
%        end
%    end
%end

imagesc(p,[0,1]); colormap(gray);


% Do something with this - maybe the old segmentation

% recursively segment the bounding box to create the list of segments
m = segment(p, x1, y1, x2, y2, ht, vt);

m = (((m - 1) * BLOCK_SIZE) + 1);

% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = segment(p, x1, y1, x2, y2, ht, vt)
% SEGMENT  Recursive subfunction that segments the rectangle passed into
%          smaller pieces using the XY cut algorithm.

% start by determining the sum of all non-background pixels in the horizontal
% and vertical directions within the co-ord box passed -- note we must use 1-
% pixel value since background pixels are 1
hsums = sum(1 - p(y1:y2, x1:x2));
vsums = sum(1 - p(y1:y2, x1:x2), 2);

% Define a "valley" as being < 8% black
VALLEY_PCT = 0.08;
hsums_pct = hsums / (y2 - y1 + 1);
vsums_pct = vsums / (x2 - x1 + 1);
hsums(hsums_pct < VALLEY_PCT) = 0;
vsums(vsums_pct < VALLEY_PCT) = 0;

% determine the longest background valley (sum value = 0) run in both
% directions
[hrunlength, hrunpos] = long_valley(hsums);
[vrunlength, vrunpos] = long_valley(vsums);

if vrunlength > vt & vrunlength >= hrunlength
    % make a horizontal cut along the vertical midpoint
    res = [segment(p, x1, y1, x2, (y1 + vrunpos), ht, vt); ...
           segment(p, x1, (y1 + vrunpos), x2, y2, ht, vt)];

elseif hrunlength > ht & hrunlength >= vrunlength
    % make a vertical cut along the horizontal midpoint
    res = [segment(p, x1, y1, (x1 + hrunpos), y2, ht, vt); ...
           segment(p, (x1 + hrunpos), y1, x2, y2, ht, vt)];
else
    % non-recursive case, don't split anything
    res = [x1, y1, x2, y2];
end


function [longlength, mid] = long_valley(sums)
% LONG_VALLEY  Subfunction that determines the length and midpoint position of
%              the longest background valley (sums value =0) run in the vector
%              passed.  If the vector is all non-zero, a length of 0 is
%              returned and the mid is undefiend (NaN).

s = 1;
e = length(sums);
currlength = 0;
longlength = 0;
mid = nan;

% strip the leading and trailing 0 runs from sums (since we want a full valley
% for our run count).
while sums(s) == 0
    s = s + 1;
end
while sums(e) == 0
    e = e - 1;
end

if s >= e
    return;
end

for i = s:e

    if sums(i) == 0
        currlength = currlength + 1;
        if currlength > longlength
            longlength = currlength;
            mid = i - floor(longlength / 2);
        end
    else
        currlength = 0;
    end
end
