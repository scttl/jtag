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
% $Id: xycut.m,v 1.6 2004-10-06 20:12:16 klaven Exp $
%
% REVISION HISTORY:
% $Log: xycut.m,v $
% Revision 1.6  2004-10-06 20:12:16  klaven
% Fixed a minor bug in xycut that occasionally added a region to the list incorrectly.
%
% Revision 1.5  2004/09/15 14:58:30  klaven
% *** empty log message ***
%
% Revision 1.4  2004/08/16 22:34:34  klaven
% New best_cuts algorithm core complete, and an implementation for xycuts.  The best_cuts implementation of xycuts produces identical results to xycuts.m.
%
% Revision 1.3  2004/07/27 22:04:34  klaven
% First run at code to find the optimal parameters for the xycut algorithm
%
% Revision 1.2  2004/06/28 16:22:39  klaven
% *** empty log message ***
%
% Revision 1.1  2004/06/19 00:27:28  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.8  2004/05/13 21:17:01  klaven
% Working with some new functions for evaluatng the segmentation.
%
% Revision 1.7  2004/04/30 01:07:04  klaven
% This is the version to use for my demo.
%
% Revision 1.6  2004/04/30 00:25:42  klaven
% xycut now uses a snap function that jumps back to the beginning of the current mark once the threshold is crossed.  The threshold is now cumulative since the start of the most recent mark.
%
% Revision 1.5  2004/04/28 18:53:54  klaven
% Tweaking the elimination of whitespace from the xycut algorithm.  In progress.
%
% Revision 1.4  2004/04/26 22:53:22  klaven
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

% default horizontal threshold (if not passed above)
%ht = 40;  % prefered ht for single-column layout
%ht = 40;  % optimized ht for jmlr
% ht = 20;  %prefered ht for double-column layout
ht = 45; %optimized ht for nips

%vt = 18;  % default vertical threshold (if not passed above)
%vt = 16; % optimized vt for jmlr
vt = 16; % optimized vt for nips


%wst = 0.009;  % minimum percent ink in whitespace to count as valley
wst = 0.0000001;

% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));

if (ischar(img_file));
    p = imread(img_file);
else;
    p = img_file;
end;

%if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
%    error('IMG_FILE must contain a single string.');
%end

if nargin >= 2
    ht = varargin{1};
    if nargin == 3
        vt = varargin{2};
    end
end

% attempt open the file and read in its pixel data
%p = imread(img_file);

% determine the initial page bounding box co-ords
%x1 = 1;
%y1 = 1;
%x2 = size(p,2);
%y2 = size(p,1);
start_seg = [1 1 size(p,2) size(p,1)];
start_seg = seg_snap(p,start_seg,wst);
x1 = start_seg(1);
y1 = start_seg(2);
x2 = start_seg(3);
y2 = start_seg(4);

% recursively segment the bounding box to create the list of segments
m = segment(p, x1, y1, x2, y2, ht, vt, wst);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = segment(p, x1, y1, x2, y2, ht, vt, wst)
% SEGMENT  Recursive subfunction that segments the rectangle passed into
%          smaller pieces using the XY cut algorithm.

oldseg = [x1 y1 x2 y2];

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
    vrunstart = vrunpos - floor(vrunlength / 2);
    vrunend = vrunpos + floor(vrunlength / 2);
    % make a horizontal cut along the vertical midpoint
    newseg1 = [x1 y1 x2 (y1 + vrunpos)];
    newseg1 = seg_snap(p,newseg1,wst);
    newseg2 = [x1 (y1 + vrunpos) x2 y2];
    newseg2 = seg_snap(p,newseg2,wst);
    if (rect_comes_before(newseg2, newseg1));
        res = ...
         [segment(p,newseg2(1),newseg2(2),newseg2(3),newseg2(4),ht,vt,wst); ...
          segment(p,newseg1(1),newseg1(2),newseg1(3),newseg1(4),ht,vt,wst)];
    else;
        res = ...
         [segment(p,newseg1(1),newseg1(2),newseg1(3),newseg1(4),ht,vt,wst); ...
          segment(p,newseg2(1),newseg2(2),newseg2(3),newseg2(4),ht,vt,wst)];
    end;
    %res = [segment(p, x1, y1, x2, (y1 + vrunpos), ht, vt, wst); ...
    %       segment(p, x1, (y1 + vrunpos), x2, y2, ht, vt, wst)];

elseif hrunlength > ht & hrunlength >= vrunlength
    hrunstart = hrunpos - floor(hrunlength / 2);
    hrunend = hrunpos + floor(hrunlength / 2);
    % make a vertical cut along the horizontal midpoint
    newseg1 = [x1 y1 (x1 + hrunpos) y2];
    newseg1 = seg_snap(p,newseg1,wst);
    newseg2 = [(x1 + hrunpos) y1 x2 y2];
    newseg2 = seg_snap(p,newseg2,wst);
    if (rect_comes_before(newseg2, newseg1));
        res = ...
         [segment(p,newseg2(1),newseg2(2),newseg2(3),newseg2(4),ht,vt,wst); ...
          segment(p,newseg1(1),newseg1(2),newseg1(3),newseg1(4),ht,vt,wst)];
    else;
        res = ...
         [segment(p,newseg1(1),newseg1(2),newseg1(3),newseg1(4),ht,vt,wst); ...
          segment(p,newseg2(1),newseg2(2),newseg2(3),newseg2(4),ht,vt,wst)];
    end;
    %res = [segment(p, x1, y1, (x1 + hrunpos), y2, ht, vt, wst); ...
    %       segment(p, (x1 + hrunpos), y1, x2, y2, ht, vt, wst)];
else
    % non-recursive case, don't split anything
    res = seg_snap(p,oldseg,wst);
    %[x1,y1,x2,y2] = snap(p,x1, y1, x2, y2,wst);
    %res = [x1,y1,x2,y2];
end


%function [left,top,right,bottom] = snap(pixels, x1, y1, x2, y2, wst)
%% loop over the 4 sides, trimming our current bounding box until we have met
%% our ink thresholds
%
%bg = 1;           % default value for background pixels
%
%left=x1; top = y1; right=x2; bottom=y2;
%
%l_done = false;
%t_done = false;
%r_done = false;
%b_done = false;
%
%l_markstart = left;
%t_markstart = top;
%r_markstart = right;
%b_markstart = bottom;
%
%
%while ~ (l_done & t_done & r_done & b_done)
%
%    if left >= right | top >= bottom
%        warning('Did not find sufficient ink.  Returning orig. subrectangle');
%        return;
%    end
%
%    if ~ l_done
%        count = sum(sum(bg - pixels(top:bottom,left)));
%        if (count == 0)
%            l_markstart = left;
%            left = left + 1;
%        else
%            count = sum(sum((bg - pixels(top:bottom,l_markstart:left))>0));
%            if count > (wst * (bottom - top + 1))
%                left = l_markstart;
%                l_done = true;
%            else
%                left = left + 1;
%            end
%        end
%    end
%
%    if ~ t_done
%        count = sum(sum(bg - pixels(top,left:right)));
%        if (count == 0)
%            t_markstart = top;
%            top = top + 1;
%        else
%            count = sum(sum((bg - pixels(t_markstart:top,left:right))>0));
%            if count > (wst * (right - left + 1))
%                top = t_markstart;
%                t_done = true;
%            else
%                top = top + 1;
%            end
%        end
%    end
%
%    if ~ r_done
%        count = sum(sum(bg - pixels(top:bottom,right)));
%        if (count == 0)
%            r_markstart = right;
%            right = right - 1;
%        else
%            count = sum(sum((bg - pixels(top:bottom,right:r_markstart))>0));
%            if count > (wst * (bottom - top + 1))
%                right = r_markstart;
%                r_done = true;
%            else
%                right = right - 1;
%            end
%        end
%    end
%
%    if ~ b_done
%
%        count = sum(sum((bg - pixels(bottom,left:right))>0));
%
%        if (count == 0)
%            b_markstart = bottom;
%            bottom = bottom - 1;
%        else
%            count = sum(sum((bg - pixels(bottom:b_markstart,left:right))>0));
%            if count > (wst * (right - left + 1))
%                bottom = b_markstart;
%                b_done = true;
%            else
%                bottom = bottom - 1;
%            end
%        end
%    end
%
%end  %end while loop





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
while (s < e) && (means(s) <= wst)
    s = s + 1;
end
while (s < e) && (means(e) <= wst)
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








