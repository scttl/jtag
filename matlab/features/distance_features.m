function res = distance_features(rects, pixels, varargin)
% DISTANCE_FEATURES   Subjects RECT to a variety of distance related features.
%
%  DISTANCE_FEATURES(RECT, PAGE, {THRESHOLD})  Runs the 4 element vector RECT
%  passed against 20 different distance features, each of which returns a
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
% $Id: distance_features.m,v 1.2 2004-07-29 20:41:56 klaven Exp $
%
% REVISION HISTORY:
% $Log: distance_features.m,v $
% Revision 1.2  2004-07-29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.6  2004/06/08 00:56:50  klaven
% Debugged new distance and density features.  Added a script to make training simpler.  Added a script to print out output.
%
% Revision 1.5  2004/06/01 21:56:54  klaven
% Modified all functions that call the feature extraction methods to call them with all the rectanges at once.
%
% Revision 1.4  2004/06/01 21:38:21  klaven
% Updated the feature extraction methods to take all the rectangles at once, rather than work one at a time.  This allows for the extraction of features that use relations between rectangles.
%
% Revision 1.3  2004/06/01 19:24:34  klaven
% Assorted minor changes.  About to re-organize.
%
% Revision 1.2  2003/08/26 21:37:50  scottl
% Added 4 new features that calculate the distance from subrectangle edges to
% associated page edges
%
% Revision 1.1  2003/08/18 15:42:50  scottl
% Initial revision.  Merger of 4 previously individually calculated distance
% features.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02;    % default threshold to use if not passed above
bg = 1;             % default value for background pixels
get_names = false;  % determine if we are looking for names only

% first do some argument sanity checking on the arguments passed
error(nargchk(0,3,nargin));

if nargin == 0
    get_names = true;
elseif nargin == 1
    error('can not pass in 1 argument.  Must be 0, 2 or 3');
else
    [r, c] = size(pixels);
    if ndims(rects) > 2 | size(rects,2) ~= 4
        error('RECT passed must have exactly 4 elements');
    end;
    if min(rects(:,1)) < 1 | min(rects(:,2)) < 1 | ...
       max(rects(:,3)) > c | max(rects(:,4)) > r;
        error('RECT passed exceeds PAGE boundaries');
    end;

    if nargin == 3
        if varargin{1} < 0 | varargin{1} > 1
            error('THRESHOLD passed must be a percentage (between 0 and 1)');
        end
        threshold = varargin{1};
    end
end

%res = {};

if get_names;
  rects = ones(1);
end;

% For future use, construct a mapping of the pixels indicating which
% (if any) region each is part of.

if (get_names == false);
  regmap = zeros(size(pixels));
  for rr = 1:size(rects,1);
    rect = rects(rr,:);
    left = rect(1);
    top = rect(2);
    right = rect(3);
    bottom = rect(4);
    regmap(top:bottom,left:right) = rr;
  end;
end;


for rr = 1:size(rects,1);
rect = rects(rr,:);

% note that all feature distances computed are normalized by the size of the
% page!!

% features 1 - 4 compute the distance from one edge of the rectangle to the
% associated edge in the "snapped" subrectangle (must contain at least
% threshold percent ink)
res(rr,1).name  = 'l_inksr_dist';
res(rr,1).norm = false;
res(rr,2).name  = 't_inksr_dist';
res(rr,2).norm = false;
res(rr,3).name  = 'r_inksr_dist';
res(rr,3).norm = false;
res(rr,4).name  = 'b_inksr_dist';
res(rr,4).norm = false;

% features 5 - 8 compute the distance from one edge of the rectangle to the
% associated edge of the page
res(rr,5).name  = 'l_page_dist';
res(rr,5).norm = true;
res(rr,6).name  = 't_page_dist';
res(rr,6).norm = true;
res(rr,7).name  = 'r_page_dist';
res(rr,7).norm = true;
res(rr,8).name  = 'b_page_dist';
res(rr,8).norm = true;

% features 9 - 12 copmute the distance from one edge of the "snapped"
% subrectangle to the associated edge of the page.  This is really the sum of
% the first and second group of features above, i.e.
% res(9) = res(1) + res(5) etc.
res(rr,9).name   = 'l_inksr_page_dist';
res(rr,9).norm = true;
res(rr,10).name  = 't_inksr_page_dist';
res(rr,10).norm = true;
res(rr,11).name  = 'r_inksr_page_dist';
res(rr,11).norm = true;
res(rr,12).name  = 'b_inksr_page_dist';
res(rr,12).norm = true;

% features 13 - 16 compute the distance from one edge of the rectangle to the
% next threshold significant non-whitespace region.
res(rr,13).name  = 'l_ws_dist';
res(rr,13).norm = false;
res(rr,14).name = 't_ws_dist';
res(rr,14).norm = false;
res(rr,15).name = 'r_ws_dist';
res(rr,15).norm = false;
res(rr,16).name = 'b_ws_dist';
res(rr,16).norm = false;

% features 17 - 20 compute the distance from one edge of the "snapped"
% subrectangle to the next threshold significant non-whitespace region.
% This is really the sum of the first and fourth group of features above, i.e.
% res(17) = res(1) + res(13) etc.
res(rr,17).name = 'l_inksr_ws_dist';
res(rr,17).norm = false;
res(rr,18).name = 't_inksr_ws_dist';
res(rr,18).norm = false;
res(rr,19).name = 'r_inksr_ws_dist';
res(rr,19).norm = false;
res(rr,20).name = 'b_inksr_ws_dist';
res(rr,20).norm = false;

res(rr,21).name = 'height';
res(rr,21).norm = false;
res(rr,22).name = 'width';
res(rr,22).norm = false;
res(rr,23).name = 'area';
res(rr,23).norm = false;
res(rr,24).name = 'height_over_width';
res(rr,24).norm = false;
res(rr,25).name = 'width_over_height';
res(rr,25).norm = false;

res(rr,26).name = 'is_centered';
res(rr,26).norm = true;

res(rr,27).name = 'on_left_edge';
res(rr,27).norm = true;
res(rr,28).name = 'on_top_edge';
res(rr,28).norm = true;
res(rr,29).name = 'on_right_edge';
res(rr,29).norm = true;
res(rr,30).name = 'on_bottom_edge';
res(rr,30).norm = true;

res(rr,31).name = 'furthest_left';
res(rr,31).norm = true;
res(rr,32).name = 'furthest_up';
res(rr,32).norm = true;
res(rr,33).name = 'furthest_right';
res(rr,33).norm = true;
res(rr,34).name = 'furthest_down';
res(rr,34).norm = true;

res(rr,35).name = 'left_neighbour_dist';
res(rr,35).norm = false;
res(rr,36).name = 'top_neighbour_dist';
res(rr,36).norm = false;
res(rr,37).name = 'right_neighbour_dist';
res(rr,37).norm = false;
res(rr,38).name = 'bottom_neighbour_dist';
res(rr,38).norm = false;

res(rr,39).name = 'left_neighbour_covers';
res(rr,39).norm = true1;
res(rr,40).name = 'top_neighbour_covers';
res(rr,40).norm = true;
res(rr,41).name = 'right_neighbour_covers';
res(rr,41).norm = true;
res(rr,42).name = 'bottom_neighbour_covers';
res(rr,42).norm = true;

res(rr,43).name = 'covers_left_neighbour';
res(rr,43).norm = true;
res(rr,44).name = 'covers_top_neighbour';
res(rr,44).norm = true;
res(rr,45).name = 'covers_right_neighbour';
res(rr,45).norm = true;
res(rr,46).name = 'covers_bottom_neighbour';
res(rr,46).norm = true;

res(rr,47).name = 'rect_order_fraction';
res(rr,47).norm = true;


if get_names
    return;
end


% get the subrectangle meeting the ink threshold (features 1 - 4).
sr = get_sr(rect, pixels, threshold);
res(rr,1).val = (sr(1) - rect(1)) / c;
res(rr,2).val = (sr(2) - rect(2)) / r;
res(rr,3).val = (rect(3) - sr(3)) / c;
res(rr,4).val = (rect(4) - sr(4)) / r;


% now calculate features 5 - 8
res(rr,5).val  = (rect(1) - 1) / c;
res(rr,6).val  = (rect(2) - 1) / r;
res(rr,7).val  = (c - rect(3)) / c;
res(rr,8).val  = (r - rect(4)) / r;

% now calculate features 9 - 12
res(rr,9).val  = res(rr,1).val + res(rr,5).val;
res(rr,10).val = res(rr,2).val + res(rr,6).val;
res(rr,11).val = res(rr,3).val + res(rr,7).val;
res(rr,12).val = res(rr,4).val + res(rr,8).val;

% now calculate the amount of whitespace from each edge (features 13 - 16).
% Note that when determining whitespace above or below a selection, the entire
% width of the page is scanned.  When determining whitespace to the left or
% right of a selection, only information at the same height as the selection
% is scanned (not above or below it).

left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);

l_done = false;
t_done = false;
r_done = false;
b_done = false;


while ~ (l_done & t_done & r_done & b_done)

    if ~ l_done
        left = left - 1;
        if left <= 1
            left = 1;
            l_done = true;
        else
            count = 0;
            for i = rect(2):rect(4)
                if pixels(i, left) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * (rect(4) - rect(2) + 1))
                l_done = true;
            end
        end
    end

    if ~ t_done
        top = top - 1;
        if top <= 1
            top = 1;
            t_done = true;
        else
            count = 0;
            for i = 1:c
                if pixels(top,i) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * c)
                t_done = true;
            end
        end
    end

    if ~ r_done
        right = right + 1;
        if right >= c
            right = c;
            r_done = true;
        else
            count = 0;
            for i = rect(2):rect(4)
                if pixels(i, right) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * (rect(4) - rect(2) + 1))
                r_done = true;
            end
        end
    end

    if ~ b_done
        bottom = bottom + 1;
        if bottom >= r
            bottom = r;
            b_done = true;
        else
            count = 0;
            for i = 1:c
                if pixels(bottom, i) ~= bg
                    count = count + 1;
                end
            end
            if count > (threshold * c)
                b_done = true;
            end
        end
    end

end  %end while loop

res(rr,13).val = (rect(1) - left) / c;
res(rr,14).val = (rect(2) - top) / r;
res(rr,15).val = (right - rect(3)) / c;
res(rr,16).val = (bottom - rect(4)) / r;


% now calculate features 17 - 20 by simply adding the corresponding element
% from features (1-4) with features (13-16)
res(rr,17).val = res(rr,1).val + res(rr,13).val;
res(rr,18).val = res(rr,2).val + res(rr,14).val;
res(rr,19).val = res(rr,3).val + res(rr,15).val;
res(rr,20).val = res(rr,4).val + res(rr,16).val;

% now calculate features 21-25, which work with the width and height.
left = rect(1);
top = rect(2);
right = rect(3);
bottom = rect(4);
width  = right - left;
height = bottom - top;

res(rr,21).val = width / r;
res(rr,22).val = height / c;
res(rr,23).val = width * height / (r*c);
res(rr,24).val = log(height / width);
res(rr,25).val = log(width / height);

% Now calculate feature 26, which estimates whether the
% region is centered or not.
ws_left = rect(1);
ws_right = c - rect(3);
if (abs(ws_left - ws_right) / c) < 0.05;
  res(rr,26).val = 1;
else
  res(rr,26).val = 0;
end;


% Calculate features 27-30, which check whether another region stands
% between this one and any edge.

% res(rr,27).name = 'on_left_edge';
if (left == 1) || (max(max(regmap(top:bottom,1:left-1))) == 0);
  res(rr,27).val = 1;
else
  res(rr,27).val = 0;
end;

%res(rr,28).name = 'on_top_edge';
if (top == 1) || (max(max(regmap(1:top-1,left:right))) == 0);
  res(rr,28).val = 1;
else
  res(rr,28).val = 0;
end;

%res(rr,29).name = 'on_right_edge';
if (right == c) || (max(max(regmap(top:bottom,right+1:c))) == 0);
  res(rr,29).val = 1;
else
  res(rr,29).val = 0;
end;

%res(rr,30).name = 'on_bottom_edge';
if (bottom == r) || (max(max(regmap(bottom+1:r,left:right))) == 0);
  res(rr,30).val = 1;
else
  res(rr,30).val = 0;
end;


% Features 31-34 represent whether there is another item closer to
% each edge of the page.

%res(rr,31).name = 'furthest_left';
if (left == 1) || (max(max(regmap(1:r,1:left-1))) == 0);
  res(rr,31).val = 1;
else
  res(rr,31).val = 0;
end;

%res(rr,32).name = 'furthest_up';
if (top == 1) || (max(max(regmap(1:top-1,1:c))) == 0);
  res(rr,32).val = 1;
else
  res(rr,32).val = 0;
end;

%res(rr,33).name = 'furthest_right';
if (right == c) || (max(max(regmap(1:r,right+1:c))) == 0);
  res(rr,33).val = 1;
else
  res(rr,33).val = 0;
end;

%res(rr,34).name = 'furthest_down';
if (bottom == r) || (max(max(regmap(bottom+1:r,1:c))) == 0);
  res(rr,34).val = 1;
else
  res(rr,34).val = 0;
end;


% Features beyond this point work with the neighbours in
% each direction.  These neighbours are calculated here.

l_neighbour = 0;
l_pt = left;
while (l_neighbour == 0) && (l_pt > 1);
  l_pt = l_pt-1;
  l_neighbour = max(regmap(top:bottom,l_pt));
end;

t_neighbour = 0;
t_pt = top;
while (t_neighbour == 0) && (t_pt > 1);
  t_pt = t_pt-1;
  t_neighbour = max(regmap(t_pt,left:right));
end;

r_neighbour = 0;
r_pt = right;
while (r_neighbour == 0) && (r_pt < c);
  r_pt = r_pt+1;
  r_neighbour = max(regmap(top:bottom,r_pt));
end;

b_neighbour = 0;
b_pt = bottom;
while (b_neighbour == 0) && (b_pt < r);
  b_pt = b_pt+1;
  b_neighbour = max(regmap(b_pt,left:right));
end;


% Featuers 35-38 are the distance to the neighbours in
% each direction.
%res(rr,35).name = 'left_neighbour_dist';
if (l_neighbour > 0);
  res(rr,35).val = (left - l_pt) / c;
else
  res(rr,35).val = left / c;
end;

%res(rr,36).name = 'top_neighbour_dist';
if (t_neighbour > 0);
  res(rr,36).val = (top - t_pt) / r;
else
  res(rr,36).val = top / r;
end;

%res(rr,37).name = 'right_neighbour_dist';
if (r_neighbour > 0);
  res(rr,37).val = (r_pt - right) / c;
else
  res(rr,37).val = (c - right) / c;
end;

%res(rr,38).name = 'bottom_neighbour_dist';
if (b_neighbour > 0);
  res(rr,38).val = (b_pt - bottom) / r;
else
  res(rr,38).val = (r - bottom) / r;
end;


% Features 39-47 deal with the sizes of the projections
% of the feature on its neighbours, and vice versa.

%res(rr,39).name = 'left_neighbour_covers';
if (l_neighbour > 0);
  res(rr,39).val = (min([rect(4),rects(l_neighbour,4)]) ...
                     - max([rect(2),rects(l_neighbour,2)]) ) / ...
                   (rect(4) - rect(2));
else
  res(rr,39).val = 0;
end;

%res(rr,40).name = 'top_neighbour_covers';
if (t_neighbour > 0);
  res(rr,40).val = (min([rect(3),rects(t_neighbour,3)]) ...
                     - max([rect(1),rects(t_neighbour,1)]) ) / ...
                   (rect(3) - rect(1));
else
  res(rr,40).val = 0;
end;

%res(rr,41).name = 'right_neighbour_covers';
if (r_neighbour > 0);
  res(rr,41).val = (min([rect(4),rects(r_neighbour,4)]) ...
                     - max([rect(2),rects(r_neighbour,2)]) ) / ...
                   (rect(4) - rect(2));
else
  res(rr,41).val = 0;
end;

%res(rr,42).name = 'bottom_neighbour_covers';
if (b_neighbour > 0);
  res(rr,42).val = (min([rect(3),rects(b_neighbour,3)]) ...
                     - max([rect(1),rects(b_neighbour,1)]) ) / ...
                   (rect(3) - rect(1));
else
  res(rr,42).val = 0;
end;

%res(rr,43).name = 'covers_left_neighbour';
if (l_neighbour > 0);
  res(rr,43).val = (min([rect(4),rects(l_neighbour,4)]) ...
                     - max([rect(2),rects(l_neighbour,2)]) ) / ...
                   (rects(l_neighbour,4) - rects(l_neighbour,2));
else
  res(rr,43).val = 0;
end;

%res(rr,44).name = 'covers_top_neighbour';
if (t_neighbour > 0);
  res(rr,44).val = (min([rect(3),rects(t_neighbour,3)]) ...
                     - max([rect(1),rects(t_neighbour,1)]) ) / ...
                   (rects(t_neighbour,3) - rects(t_neighbour,1));
else
  res(rr,44).val = 0;
end;

%res(rr,45).name = 'covers_right_neighbour';
if (r_neighbour > 0);
  res(rr,45).val = (min([rect(4),rects(r_neighbour,4)]) ...
                     - max([rect(2),rects(r_neighbour,2)]) ) / ...
                   (rects(r_neighbour,4) - rects(r_neighbour,2));
else
  res(rr,45).val = 0;
end;

%res(rr,46).name = 'covers_bottom_neighbour';
if (b_neighbour > 0);
  res(rr,46).val = (min([rect(3),rects(b_neighbour,3)]) ...
                     - max([rect(1),rects(b_neighbour,1)]) ) / ...
                   (rects(b_neighbour,3) - rects(b_neighbour,1));
else
  res(rr,46).val = 0;
end;

%res(rr,47).name = 'rect_order_fraction';
%Build a fake training data structure so that we can sort the regions.
rnum = 0;
for i=1:size(rects,1);
    if (rect_comes_before(rects(i,:),rects(rr,:)));
        rnum = rnum + 1;
    end;
end;
if (size(rects,1)==1);
    res(rr,47).val = 0;
else;
    res(rr,47).val = (rnum / (size(rects,1)-1));
end;

end;
