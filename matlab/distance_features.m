function res = distance_features(rect, pixels, varargin)
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
% $Id: distance_features.m,v 1.3 2004-06-01 19:24:34 klaven Exp $
%
% REVISION HISTORY:
% $Log: distance_features.m,v $
% Revision 1.3  2004-06-01 19:24:34  klaven
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
end

res = {};

% note that all feature distances computed are normalized by the size of the
% page!!

% features 1 - 4 compute the distance from one edge of the rectangle to the
% associated edge in the "snapped" subrectangle (must contain at least
% threshold percent ink)
res{1}.name  = 'l_inksr_dist';
res{2}.name  = 't_inksr_dist';
res{3}.name  = 'r_inksr_dist';
res{4}.name  = 'b_inksr_dist';

% features 5 - 8 compute the distance from one edge of the rectangle to the
% associated edge of the page
res{5}.name  = 'l_page_dist';
res{6}.name  = 't_page_dist';
res{7}.name  = 'r_page_dist';
res{8}.name  = 'b_page_dist';

% features 9 - 12 copmute the distance from one edge of the "snapped"
% subrectangle to the associated edge of the page.  This is really the sum of
% the first and second group of features above, i.e.
% res{9} = res{1} + res{5} etc.
res{9}.name   = 'l_inksr_page_dist';
res{10}.name  = 't_inksr_page_dist';
res{11}.name  = 'r_inksr_page_dist';
res{12}.name  = 'b_inksr_page_dist';

% features 13 - 16 compute the distance from one edge of the rectangle to the
% next threshold significant non-whitespace region.
res{13}.name  = 'l_ws_dist';
res{14}.name = 't_ws_dist';
res{15}.name = 'r_ws_dist';
res{16}.name = 'b_ws_dist';

% features 17 - 20 compute the distance from one edge of the "snapped"
% subrectangle to the next threshold significant non-whitespace region.
% This is really the sum of the first and fourth group of features above, i.e.
% res{17} = res{1} + res{13} etc.
res{17}.name = 'l_inksr_ws_dist';
res{18}.name = 't_inksr_ws_dist';
res{19}.name = 'r_inksr_ws_dist';
res{20}.name = 'b_inksr_ws_dist';


if get_names
    return;
end


% get the subrectangle meeting the ink threshold (features 1 - 4).
sr = get_sr(rect, pixels, threshold);
res{1}.val = (sr(1) - rect(1)) / c;
res{2}.val = (sr(2) - rect(2)) / r;
res{3}.val = (rect(3) - sr(3)) / c;
res{4}.val = (rect(4) - sr(4)) / r;


% now calculate features 5 - 8
res{5}.val  = (rect(1) - 1) / c;
res{6}.val  = (rect(2) - 1) / r;
res{7}.val  = (c - rect(3)) / c;
res{8}.val  = (r - rect(4)) / r;

% now calculate features 9 - 12
res{9}.val  = res{1}.val + res{5}.val;
res{10}.val = res{2}.val + res{6}.val;
res{11}.val = res{3}.val + res{7}.val;
res{12}.val = res{4}.val + res{8}.val;

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

res{13}.val = (rect(1) - left) / c;
res{14}.val = (rect(2) - top) / r;
res{15}.val = (right - rect(3)) / c;
res{16}.val = (bottom - rect(4)) / r;


% now calculate features 17 - 20 by simply adding the corresponding element
% from features (1-4) with features (13-16)
res{17}.val = res{1}.val + res{13}.val;
res{18}.val = res{2}.val + res{14}.val;
res{19}.val = res{3}.val + res{15}.val;
res{20}.val = res{4}.val + res{16}.val;
