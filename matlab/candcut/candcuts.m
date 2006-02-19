function [tl, tr, bl , br] = candcuts(img_file, varargin)
% CANDCUTS Decompose the image passed into 4 sets of x,y co-ordinates
%          representing potential top-left, top-right, bottom-left, and
%          bottom-right points to segment the page at.  This
%          procedure uses an alogrithm similar to the xycut segmentation alg.
%
%   [TL, TR, BL, BR] = CANDCUTS(IMG_FILE, {H_THRESH, V_THRESH}, {TOLERANCE}) 
%   Determines the best x,y co-ordinate points in the document at which to
%   potentially cut to segment the IMG_FILE passed (either the file itself, or 
%   its pixel matrix representation.
%
%   This is done in a recursive fashion similar to the xycuts algorithm, 
%   bottoming out when the current area under consideration has no signifcant 
%   transition from ink to no-ink (or no-ink to ink) across the area or down
%   the area
%
%   The 4 nx2 matrices returned each list the horizontal and vertical 
%   co-ordinates of the candiate point, one set for top-left points, one for
%   bottom-right points etc.
%
%   H_THRESH and V_THRESH are optional, and give the number of consecutive 
%   rows (H_THRESH) or columns (V_THRESH) that have to have ink (or no-ink)
%   in order to be considered a potential transition.  If not specified
%   H_THRESH defaults to: 40 and V_THRESH defaults to: 20
%
%   TOLERANCE is also optional, and gives a percentage of pixels that can
%   be considered noisy (foreground in a background sum) when determining 
%   cut points.  This value defaults to 0.  As an example, consider a 
%   tolerance of .10.  This means that when determining which rows are 
%   considered background the number of non-background pixels in that row must 
%   be at most 10%.
%
%   If there is a problem at any point, an error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: candcuts.m,v 1.2 2006-02-19 18:29:34 scottl Exp $
%
% REVISION HISTORY:
% $Log: candcuts.m,v $
% Revision 1.2  2006-02-19 18:29:34  scottl
% Pushed pixels in by 1 on top and left to ensure we always reduce box size.
%
% Revision 1.1  2005/11/16 18:04:19  scottl
% Initial revision.
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% default horizontal threshold (if not passed above)
ht = 20;  % prefered ht for single-column layout
vt = 19;  % default vertical threshold (if not passed above)
tol = 0;  % default pixel noise tolerance (if not passed above)


% first do some argument sanity checking on the argument passed
error(nargchk(1,4,nargin));

% open and read the file contents, note that imread has the convention of
% 1 for background pixels, so we reverse that.  We also assume that if
% a matrix of pixels are passed, they have not yet been converted.
if (ischar(img_file));
    p = imread(img_file);
else;
    p = img_file;
end;
p = ~p;

if nargin >= 2
    ht = varargin{1};
    if nargin >= 3
        vt = varargin{2};
        if nargin == 4
            tol = varargin{3};
            if tol < 0 | tol > 1
                error('tolerance passed, must be between 0 and 1');
            end
        end
    end
end

% determine the initial page bounding box co-ords
x1 = 1;
y1 = 1;
x2 = size(p,2);
y2 = size(p,1);

% recursively chop up the bounding box to create the list of candidate points
tl = [];
tr = [];
bl = [];
br = [];
[tl, tr, bl, br] = get_cands(p, tl, tr, bl, br, x1, y1, x2, y2, ht, vt, tol);



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tl, tr, bl, br] = get_cands(p, tl, tr, bl, br, x1, y1, x2, y2, ...
                                      ht, vt, tol)
% GET_CANDS  Recursive subfunction that segments the rectangle passed into
%            smaller pieces using the XY cut algorithm.

if x1 >= x2 | y1 >= y2
    return;
end

cand_tops = [];
cand_bots = [];
cand_lefts = [];
cand_rights = [];

% start by determining the sum of all non-background pixels in the horizontal
% and vertical directions within the co-ord box passed.
row_sums = sum(p(y1:y2, x1:x2),2);
col_sums = sum(p(y1:y2, x1:x2),1);

%setup the row and column tolerance in terms of # of pixels
r_tol = round(tol * length(col_sums));
c_tol = round(tol * length(row_sums));

% now get all the row transition points that are longer than vt
if row_sums(1) > r_tol
    % starting inside a segment (i.e. in foreground pixels)
    in_fg = true;
    cand_tops = y1;
else
    in_fg = false;
end
    
count = 1;
first_seg = true;

for i=2:length(row_sums)
    if (row_sums(i) > r_tol & in_fg) | (row_sums(i) <= r_tol & ~ in_fg)
        count = count + 1;
    else
        %transition.  See if we should add this point
        if ~ in_fg 
            if count > vt | first_seg
                %passed threshold, add the point
                %transition TO a foreground pixel, add this pixel to list
                cand_tops = [cand_tops, (y1 - 1) + i];
            else
                %previous whitespace run not wide enough, remove our most
                %recently added fg -> bg transition point from the list
                if ~ first_seg
                    cand_bots = cand_bots(1:length(cand_bots) -1);
                    if length(cand_bots) == 0
                        %back in first segment again
                        first_seg = true;
                    end
                end
                %don't add this transition to candidate cut points
            end
            in_fg = true;
            count = 1;
       else
            %transition TO a background pixel, add previous pixel to list
            %we always add this point irregardless of the run length.  If its
            %following background run is too short, we delete it later.
            cand_bots = [cand_bots, (y1 - 1) + i - 1];
            in_fg = false;
            count = 1;
            first_seg = false;
        end
    end
end

if first_seg
    %remove our sole cand_tops point since we never transitioned
    cand_tops = [];
elseif in_fg
    %we've transitioned at least once, but haven't completed our final box,
    %so add the endpoint
    cand_bots = [cand_bots, y2];
end


% now get all the column transition points that are longer than ht
if col_sums(1) > c_tol
    % starting inside a segment (i.e. in foreground pixels)
    in_fg = true;
    cand_lefts = x1;
else
    in_fg = false;
end

count = 1;
first_seg = true;

for i=2:length(col_sums)
    if (col_sums(i) > c_tol & in_fg) | (col_sums(i) <= c_tol & ~ in_fg)
        count = count + 1;
    else
        %transition.  See if we should add this point
        if ~ in_fg
            if count > ht | first_seg
                %passed threshold, add the point
                %transition to a foreground pixel
                cand_lefts = [cand_lefts, (x1 - 1) + i];
            else
                %previous whitespace run not wide enough, remove our most
                %recently added fg -> bg transition point from the list
                if ~ first_seg
                    cand_rights = cand_rights(1:length(cand_rights) - 1);
                    if length(cand_rights) == 0
                        %back in first segment again
                        first_seg = true;
                    end
                end
                %don't add this transition to our candidates either.
            end
            in_fg = true;
            count = 1;
        else
            %transition to a background pixel.
            %we always add this point irregardless of the run length.  If its
            %following background run is too short, we delete it later.
            cand_rights = [cand_rights, (x1 - 1) + i - 1];
            in_fg = false;
            count = 1;
            first_seg = false;
        end
    end
end

if first_seg
    %remove our sole cand_lefts point since we never transitioned
    cand_lefts = [];
elseif in_fg
    %we've transitioned at least once, but haven't completed our final box,
    %so add the endpoint
    cand_rights = [cand_rights, x2];
end

if length(cand_tops) == 0 & length(cand_lefts) == 0 ...
    & length(cand_bots) == 0 & length(cand_rights) == 0
    %no candidates in this area.  Done!
    return;
elseif (length(cand_tops) == 0 & length(cand_bots) == 0) ...
    & (length(cand_lefts) ~= 0 | length(cand_rights) ~= 0)
    %add the horizontal endpoints as candidates
    cand_tops = [y1];
    cand_bots = [y2];
elseif (length(cand_tops) ~= 0 | length(cand_bots) ~= 0) ...
    & (length(cand_lefts) == 0 | length(cand_rights) == 0)
    %add the vertical endpoints as candidates
    cand_lefts = [x1];
    cand_rights = [x2];
end

%sanity check to ensure we've closed all boxes
if length(cand_tops) ~= length(cand_bots)
    cand_tops
    cand_bots
    x1
    y1
    x2
    y2
    error('cand tops: %d cand_bots: %d\n', length(cand_tops), ...
         length(cand_bots));
elseif length(cand_lefts) ~= length(cand_rights)
    cand_lefts
    cand_rights
    x1
    y1
    x2
    y2
    error('cand lefts: %d cand_rights: %d\n', length(cand_lefts), ...
         length(cand_rights));
end

tl = [];
tr = [];
bl = [];
br = [];

% now recurse the boxes formed from the new points
for i=1:length(cand_tops)
    for j=1:length(cand_lefts)
        if cand_lefts(j) +1 >= cand_rights(j) | cand_tops(i) +1 >= cand_bots(i)
            %candidate box too narrow, skip it
            continue;
        end
        [ttl,ttr,tbl,tbr] = get_cands(p, [], [], [], [], ...
              cand_lefts(j)+1, cand_tops(i)+1, ...
              cand_rights(j)-1, cand_bots(i)-1, ht, vt, tol);
        if length(ttl) == 0 & length(ttr) == 0 & length(tbl) == 0 ...
            & length(tbr) == 0
            %no cut points, just add the original box
            tl = [tl; cand_lefts(j), cand_tops(i)];
            tr = [tr; cand_rights(j), cand_tops(i)];
            bl = [bl; cand_lefts(j), cand_bots(i)];
            br = [br; cand_rights(j), cand_bots(i)];
        else
            % add the new points only
            tl = [tl; ttl];
            tr = [tr; ttr];
            bl = [bl; tbl];
            br = [br; tbr];
        end
    end
end
