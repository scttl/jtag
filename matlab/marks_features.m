function res = marks_features(rects, pixels, varargin)
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
% $Id: marks_features.m,v 1.1 2004-06-09 19:20:17 klaven Exp $
%
% REVISION HISTORY:
% $Log: marks_features.m,v $
% Revision 1.1  2004-06-09 19:20:17  klaven
% Started working on marks-based features.
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

    if ndims(rects) > 2 | size(rects,2) ~= 4
        error('Each RECT passed must have exactly 4 elements');
    end;
    if min(rects(:,1)) < 1 | min(rects(:,2)) < 1 | ...
       max(rects(:,3)) > c | max(rects(:,4)) > r;
        error('RECT passed exceeds PAGE boundaries');
    end
    if nargin == 3
        if varargin{1} < 0 | varargin{1} > 1
            error('THRESHOLD passed must be a percentage (between 0 and 1)');
        end
        threshold = varargin{1};
    end
end

%res = {};


if get_names
    rects = ones(1);
end

for rr=1:size(rects,1);
rect = rects(rr,:);

res(rr,1).name  = 'num_marks';

res(rr,2).name  = 'marks_per_hundred_pixels';

res(rr,3).name = 'pixels_per_mark';

res(rr,4).name = 'pixels_in_largest_mark';

res(rr,5).name = 'largest_mark_height';

res(rr,6).name = 'largest_mark_width';

res(rr,7).name = 'largets_mark_area';

res(rr,8).name = 'highest_mark_height';

res(rr,9).name = 'highest_mark_width';

res(rr,10).name = 'widest_mark_height';

res(rr,11).name = 'widest_mark_width';


if get_names
    return;
end

% calculate the mark_map for this region.

left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);



markmap = zeros(bottom-top+1,right-left+1);
mm = 0;
for j=top:bottom;
  for i=left:right;
    x = i - left + 1;
    y = j - top + 1;
    if (pixels(j,i) ~= bg);
      if (y == 1);
        if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
        p1 = 0; p2 = 0; p3 = 0;
      else;
        if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
        if (x == 1); p1 = 0; else; p1 = markmap(y-1,x-1); end;
        p2 = markmap(y-1,x);
        if (i == right); p3 = 0; else; p3 = markmap(y-1,x+1); end;
      end;
      markmap(y,x) = max([p0,p1,p2,p3]);
      if (markmap(y,x) == 0);
        mm = mm + 1;
        markmap(y,x) = mm;
      end;
    end;
  end;
end;

changed = true;
while changed;
    changed = false;
    oldmarkmap = markmap(:,:);
    for j=top:bottom;
      for i=left:right;
        x = i - left + 1;
        y = j - top + 1;
        if (pixels(j,i) ~= bg);
          if (y == 1);
            if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
            p1 = 0; p2 = 0; p3 = 0;
          else;
            if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
            if (x == 1); p1 = 0; else; p1 = markmap(y-1,x-1); end;
            p2 = markmap(y-1,x);
            if (i == right); p3 = 0; else; p3 = markmap(y-1,x+1); end;
          end;
          markmap(y,x) = max([p0,p1,p2,p3,markmap(y,x)]);
        end;
      end;
    end;

    for j=((bottom + top) - (top:bottom));
      for i=((right + left) - (left:right));
        x = i - left + 1;
        y = j - top + 1;
        if (pixels(j,i) ~= bg);
          if (j == bottom);
            if (i == right); p0 = 0; else; p0 = markmap(y,x+1); end;
            p1 = 0; p2 = 0; p3 = 0;
          else;
            if (i == right); p0 = 0; else; p0 = markmap(y,x+1); end;
            if (x == 1); p1 = 0; else; p1 = markmap(y+1,x-1); end;
            p2 = markmap(y+1,x);
            if (i == right); p3 = 0; else; p3 = markmap(y+1,x+1); end;
          end;
          markmap(y,x) = max([p0,p1,p2,p3,markmap(y,x)]);
        end;
      end;
    end;

    if (max(max(abs(oldmarkmap - markmap))) > 0);
      changed = true;
    end;
end;

marknum = 0;
oldmarkmap = markmap;
markmap = zeros(size(markmap));
for i = 1:mm;
  [x,y] = find(oldmarkmap == i);
  if (length(x) > 0);
    marknum = marknum + 1;
    marks(marknum).x = x + left - 1;
    marks(marknum).y = y + top - 1;
    for (nn = 1:length(x));
      markmap(x(nn),y(nn)) = marknum;
    end;
  end;
end;

% At this point, markmap and marks are both correct.
% Now we can start computing features.

res = marks;

end;
