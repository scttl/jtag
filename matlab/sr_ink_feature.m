function s = sr_ink_feature(rect, pixels, varargin)
% SR_INK_FEATURE   Returns the subrectangle bounding box within the rectangle
%                  passed that meets an ink percentage threshold.
%
%  SR_INK_FEATURE(RECT, PAGE, {THRESHOLD})  This feature attempts to shrink the 
%  sides of 4 element vector RECT passed, working in a clockwise manner,
%  until the number of non-background PAGE pixels counted for the side currently
%  under consideration is larger than THRESHOLD percentage passed.  If 
%  THRESHOLD is not specified it defaults to 2 percent of the total pixels of 
%  that side. The return value is a 4 element row vector listing the left,
%  top, bottom, and right pixel co-ords of the subrectangle.


% CVS INFO %
%%%%%%%%%%%%
% $Id: sr_ink_feature.m,v 1.4 2003-07-24 19:24:52 scottl Exp $
% 
% REVISION HISTORY:
% $Log: sr_ink_feature.m,v $
% Revision 1.4  2003-07-24 19:24:52  scottl
% Changed threshold to a value between 0 and 1 (not 100).
% Return a row vector instead of a column vector.
%
% Revision 1.3  2003/07/23 22:28:51  scottl
% Small bugfix for when selection location begins at 1,1.
%
% Revision 1.2  2003/07/23 21:31:03  scottl
% Fixed bug involving passed threshold value.
%
% Revision 1.1  2003/07/23 20:11:24  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02;  % default threshold to use if not passed above
bg = 1;           % default value for background pixels


% first do some argument sanity checking on the arguments passed
error(nargchk(2,3,nargin));

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

% loop over the 4 sides, trimming our current bounding box until we have met
% our ink thresholds

left   = rect(1);
top    = rect(2);
right  = rect(3);
bottom = rect(4);

l_done = false;
t_done = false;
r_done = false;
b_done = false;

while ~ (l_done & t_done & r_done & b_done)

    if left >= right | top >= bottom
        warning('Did not find sufficient ink.  Returning empty subrectangle');
        s = [];
        return;
    end

    if ~ l_done
        count = 0;
        for i = top:bottom
            if pixels(i, left) ~= bg
                count = count + 1;
            end
        end
        if count > (threshold * (bottom - top + 1))
            l_done = true;
        else
            left = left + 1;
        end
    end
    
    if ~ t_done
        count = 0;
        for i = left:right
            if pixels(top,i) ~= bg
                count = count + 1;
            end
        end
        if count > (threshold * (right - left + 1))
            t_done = true;
        else
            top = top + 1;
        end
    end
    
    if ~ r_done
        count = 0;
        for i = top:bottom
            if pixels(i, right) ~= bg
                count = count + 1;
            end
        end
        if count > (threshold * (bottom - top + 1))
            r_done = true;
        else
            right = right - 1;
        end
    end
    
    if ~ b_done
        count = 0;
        for i = left:right
            if pixels(bottom, i) ~= bg
                count = count + 1;
            end
        end
        if count > (threshold * (right - left + 1))
            b_done = true;
        else
            bottom = bottom - 1;
        end
    end
    
end  %end while loop

s = [left top right bottom];
