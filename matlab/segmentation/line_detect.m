function rects = line_detect(pixels, rect)
% LINE_DETECT    Segment the 1x4 RECT selection, based on horizontal lines
%                detected in the image matrix PIXELS.
%
%   RECTS = LINE_DETECT(PIXELS, RECT)  Further segments the single selection
%   RECT passed, based on its horizontal sum values of the image pixel values
%   found in the matrix PIXELS, outputting one or more new selection
%   rectangles in RECTS.
%   
%   The nx4 matrix RECTS returned lists the left,top,bottom,right co-ordinates 
%   of each of the n segments created.
%
%   If there is a problem at any point, an error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: line_detect.m,v 1.1 2004-06-19 00:27:28 klaven Exp $
% 
% REVISION HISTORY:
% $Log: line_detect.m,v $
% Revision 1.1  2004-06-19 00:27:28  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.2  2003/08/13 19:30:49  scottl
% Fixed bug in bounds check ordering, and changed when first_y gets updated.
%
% Revision 1.1  2003/08/12 22:26:17  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

min_thresh = 9; % min. length of non-bg pixels that must be found for line to be
                % considered non-zero

split_thresh = .40; % percentage of difference between successive groupings
                    % that must exist before they will be split into 2

% first do some argument sanity checking on the argument passed
error(nargchk(2,2,nargin));

if size(rect) ~= [1,4]
    error('RECT must contain a single 4 column selection.');
end

% ensure the rect selection lies within pixel boundaries
if rect(1,1) < 1 | rect(1,2) < 1 | rect(1,3) > size(pixels,2) | ...
                   rect(1,4) > size(pixels,1)
    error('RECT co-ords do not entirely lie within PIXEL bounds');
end

first_y = rect(1,2);
rects = [];

% calculate and compare pixel rowlengths (grouped & averaged between whitespace)
prev_avg = nan;
curr = [];
row_num = first_y;
while row_num <= rect(1,4)
    blank_start = row_num;

    while row_num <= rect(1,4) & non_bg_length(pixels(row_num,:)) < min_thresh
        row_num = row_num + 1;
    end

    if row_num > rect(1,4)
        mid_break = false;
        break;
    end

    % calculate the midpoint of whitespace for rectangle segmentation
    second_y = blank_start + floor(abs(row_num - blank_start) / 2);

    % transition from blank --> non-blank

    while row_num <= rect(1,4) & non_bg_length(pixels(row_num,:)) >= min_thresh
       curr = [curr; non_bg_length(pixels(row_num,:))];
       row_num = row_num + 1;
    end

    if row_num > rect(1,4)
        mid_break = true;
        break;
    end

    % transition from non-blank --> blank

    % determine if there is significant diff. between previous average and 
    % this one
    diff_val = abs(prev_avg - mean(curr)) / max([prev_avg mean(curr)]);
    if prev_avg ~= nan & diff_val >= split_thresh

       % split the rectangle horizontally at the appropriate point
       rects = [rects; rect(1,1) first_y rect(1,3) second_y];
       first_y = second_y;
    end
    prev_avg = mean(curr);
    curr = [];
end

% now add/update the last rectangle
if prev_avg == nan | mid_break == true | size(rects,1) == 0
    rects = [rects; rect(1,1) first_y rect(1,3) rect(1,4)];
else
    rects(size(rects,1),4) = rect(1,4);
end



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = non_bg_sum(pixels)
% NON_BG_SUM    Returns the sum along one dimension of the pixels passed of
%               the quantity of non-background coloured pixels.  Note that
%               PIXELS must be either a row vector or column vector.
%
% **Note**: Thus subfunction not currently in use.

bg_val = 1;  % background colour pixel value
val = 0;

for i = 1:length(pixels)
    if pixels(i) ~= bg_val
        val = val + 1;
    end
end


function val = non_bg_length(pixels)
% NON_BG_LENGTH   Returns the distance (in pixel length) between the first and
%                 last significant amounts of pixels alone one dimension of the 
%                 PIXELS vector passed.

bg_val = 1;  % background colour pixel value
min_thresh = 1; % run of consecutive pixels which must be found to be
                % considered significant
val = 0;

i = 1;
while i + min_thresh - 1 <= length(pixels)
    if pixels(i:(i + min_thresh - 1)) ~= bg_val
        break;
    else
        i = i + 1;
    end
end

j = length(pixels);
while j - min_thresh + 1 >= i
    if pixels((j - min_thresh + 1):j) ~= bg_val
        break;
    else
        j = j - 1;
    end
end

if j - min_thresh + 1 >= i
    val = j - i + 1;
end

