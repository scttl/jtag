function res = marks_features(rects, pixels, varargin)
% DENSITY_FEATURES   Subjects RECT to a variety of density related features.
%
%  DENSITY_FEATURES(RECT, PAGE, {THRESHOLD})  Runs the 4 element vector RECT
%  passed against 2 different desnsity features, each of which returns a
%  scalar.val.  These.vals along with the feature name are built up as
%  fields in a struct, with one entry for each feature.  These entries are
%  combined in a cell array and returned as RES.
%
%  If THRESHOLD is specified, it should be given as a percentage (between
%  0 and 1), determining the amount of non-background pixels that must be found
%  for the side to be considered significant.  If not specified it defaults to
%  2 percent.


% CVS INFO %
%%%%%%%%%%%%
% $Id: marks_features.m,v 1.4 2004-08-16 22:38:10 klaven Exp $
%
% REVISION HISTORY:
% $Log: marks_features.m,v $
% Revision 1.4  2004-08-16 22:38:10  klaven
% Functions that extract features now work with a bunch of boolean variables to turn the features off and on.
%
% Revision 1.3  2004/07/29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.2  2004/06/28 16:22:38  klaven
% *** empty log message ***
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.2  2004/06/14 16:25:19  klaven
% Completed the marks-based features.  Still need to test them to make sure they are behaving.
%
% Revision 1.1  2004/06/09 19:20:17  klaven
% Started working on marks-based features.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02;    % default threshold to use if not passed above
bg = 1;             % default.val for background pixels
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


% Number of marks in the region.
res(rr,1).name  = 'num_marks';
res(rr,1).norm = false;

% Number of marks per hundred pixels.  Essentially, marks per unit area.
res(rr,2).name  = 'marks_per_hundred_pixels';
res(rr,2).norm = false;

% Number of marks per unit width.
res(rr,3).name = 'marks_per_pixel_wide';
res(rr,3).norm = false;

% Number of marks per unit height.
res(rr,4).name = 'marks_per_pixel_high';
res(rr,4).norm = false;

% Average number of pixels in each mark.
res(rr,5).name = 'avg_pixels_per_mark';
res(rr,5).norm = false;

% Standard deviation of number of pixels in each mark.
res(rr,6).name = 'std_pixels_per_mark';
res(rr,6).norm = false;

% Number of pixels in the single largest mark.
res(rr,7).name = 'pixels_in_largest_mark';
res(rr,7).norm = false;

% Height of the largest mark.
res(rr,8).name = 'largest_mark_height';
res(rr,8).norm = false;

% Width of the largest mark.
res(rr,9).name = 'largest_mark_width';
res(rr,9).norm = false;

% Area (Height * Width) of the largest mark
res(rr,10).name = 'largets_mark_area';
res(rr,10).norm = false;

% Height of the highest mark.
res(rr,11).name = 'highest_mark_height';
res(rr,11).norm = false;

% Width of the highest mark.
res(rr,12).name = 'highest_mark_width';
res(rr,12).norm = false;

% Height of the widest mark.
res(rr,13).name = 'widest_mark_height';
res(rr,13).norm = false;

% Width of the widest mark.
res(rr,14).name = 'widest_mark_width';
res(rr,14).norm = false;

if get_names
    return;
end

left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);


% % calculate the mark_map for this region.
% 
% 
% markmap = zeros(bottom-top+1,right-left+1);
% mm = 0;
% for j=top:bottom;
%   for i=left:right;
%     x = i - left + 1;
%     y = j - top + 1;
%     if (pixels(j,i) ~= bg);
%       if (y == 1);
%         if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
%         p1 = 0; p2 = 0; p3 = 0;
%       else;
%         if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
%         if (x == 1); p1 = 0; else; p1 = markmap(y-1,x-1); end;
%         p2 = markmap(y-1,x);
%         if (i == right); p3 = 0; else; p3 = markmap(y-1,x+1); end;
%       end;
%       markmap(y,x) = max([p0,p1,p2,p3]);
%       if (markmap(y,x) == 0);
%         mm = mm + 1;
%         markmap(y,x) = mm;
%       end;
%     end;
%   end;
% end;
% 
% changed = true;
% while changed;
%     changed = false;
%     oldmarkmap = markmap(:,:);
%     for j=top:bottom;
%       for i=left:right;
%         x = i - left + 1;
%         y = j - top + 1;
%         if (pixels(j,i) ~= bg);
%           if (y == 1);
%             if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
%             p1 = 0; p2 = 0; p3 = 0;
%           else;
%             if (x == 1); p0 = 0; else; p0 = markmap(y,x-1); end;
%             if (x == 1); p1 = 0; else; p1 = markmap(y-1,x-1); end;
%             p2 = markmap(y-1,x);
%             if (i == right); p3 = 0; else; p3 = markmap(y-1,x+1); end;
%           end;
%           markmap(y,x) = max([p0,p1,p2,p3,markmap(y,x)]);
%         end;
%       end;
%     end;
% 
%     for j=((bottom + top) - (top:bottom));
%       for i=((right + left) - (left:right));
%         x = i - left + 1;
%         y = j - top + 1;
%         if (pixels(j,i) ~= bg);
%           if (j == bottom);
%             if (i == right); p0 = 0; else; p0 = markmap(y,x+1); end;
%             p1 = 0; p2 = 0; p3 = 0;
%           else;
%             if (i == right); p0 = 0; else; p0 = markmap(y,x+1); end;
%             if (x == 1); p1 = 0; else; p1 = markmap(y+1,x-1); end;
%             p2 = markmap(y+1,x);
%             if (i == right); p3 = 0; else; p3 = markmap(y+1,x+1); end;
%           end;
%           markmap(y,x) = max([p0,p1,p2,p3,markmap(y,x)]);
%         end;
%       end;
%     end;
% 
%     if (max(max(abs(oldmarkmap - markmap))) > 0);
%       changed = true;
%     end;
% end;
% 
% nummarks = 0;
% oldmarkmap = markmap;
% markmap = zeros(size(markmap));
% for i = 1:mm;
%   [x,y] = find(oldmarkmap == i);
%   if (length(x) > 0);
%     nummarks = nummarks + 1;
%     marks(nummarks).x = x + left - 1;
%     marks(nummarks).y = y + top - 1;
%     for (nn = 1:length(x));
%       markmap(x(nn),y(nn)) = nummarks;
%     end;
%   end;
% end;
% 
% % At this point, markmap and marks are both correct.
% % Now we can start computing features.

[markmap, nummarks] = bwlabel((bg - pixels(top:bottom, left:right)),8);
for i = 1:nummarks;
  [x,y] = find(markmap == i);
  if (length(x) > 0);
    marks(i).x = x + left - 1;
    marks(i).y = y + top - 1;
  end;
end;
% 
% % At this point, markmap and marks are both correct.
% % Now we can start computing features.


% Number of marks in the region.
% res(rr,1).name  = 'num_marks';
res(rr,1).val = nummarks;

% Number of marks per hundred pixels.  Essentially, marks per unit area.
% res(rr,2).name  = 'marks_per_hundred_pixels';
res(rr,2).val = nummarks / ((right - left + 1) * (bottom-top+1) / 100);

% Number of marks per unit width.
% res(rr,3).name = 'marks_per_width';
res(rr,3).val = nummarks / ((right - left + 1) / 10);

% Number of marks per unit height.
% res(rr,4).name = 'marks_per_pixel_high';
res(rr,4).val = nummarks / ((bottom - top + 1) / 10);

% Average number of pixels in each mark.
% res(rr,5).name = 'avg_pixels_per_mark';
for i=1:nummarks;
  mpix(i) = length([marks(i).x]);
end;
res(rr,5).val = mean(mpix);

% Standard deviation of number of pixels in each mark.
% rev(rr,6).name = 'stddev_pixels_per_mark';
res(rr,6).val = std(mpix);

% Number of pixels in the single largest mark.
% res(rr,7).name = 'pixels_in_largest_mark';
[tmp,largest] = max(mpix);
res(rr,7).val = tmp;

% Height of the largest mark.
% res(rr,8).name = 'largest_mark_height';
res(rr,8).val = (max([marks(largest).y]) - min([marks(largest).y]) + 1) / 10;

% Width of the largest mark.
% res(rr,9).name = 'largest_mark_width';
res(rr,9).val = (max([marks(largest).x]) - min([marks(largest).x]) + 1) / 10;

% Area (Height * Width) of the largest mark
% res(rr,10).name = 'largets_mark_area';
res(rr,10).val = (max([marks(largest).y])-min([marks(largest).y])+1) * ...
                   (max([marks(largest).x])-min([marks(largest).x])+1) / ...
                   100;

% Height of the highest mark.
% res(rr,11).name = 'highest_mark_height';
for i=1:length(marks);
  heights(i) = max([marks(i).y]) - min([marks(i).y]) + 1;
  widths(i) = max([marks(i).x]) - min([marks(i).x]) + 1;
end;
[tmp, highest] = max(heights);
res(rr,11).val = tmp;

% Width of the highest mark.
% res(rr,12).name = 'highest_mark_width';
res(rr,12).val = widths(highest);

% Height of the widest mark.
% res(rr,13).name = 'widest_mark_height';
[tmp, widest] = max(widths);
res(rr,13).val = heights(widest);

% Width of the widest mark.
% res(rr,14).name = 'widest_mark_width';
res(rr,14).val = tmp;

end;
