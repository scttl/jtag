function res = mark_candidates(img_file, varargin)
% MARK_CANDIDATES  Attempts to mark up the IMG_FILE passed showing where
%                  candidate cut points would be via a red cross drawn
%                  directly onto the page.  This new image is saved under the
%                  extension passed (or .cc.<old_extn> if none given).
%
%   RES = MARK_CANDIDATES(IMG_FILE, {NEW_EXT}, {HT}, {VT}, {TOL})  Opens the 
%   IMG_FILE passed, then determines a collection of candidate cut points
%   on the page.  These locations are then altered to shown an overlaid image
%   at that point (a red cross), and the file is saved in the current
%   directory under the extension specified in NEW_EXT (or .cc.tif otherwise).
%
%   One can also control the thresholds for candidate cut by setting values
%   for HT and VT (horizontal and vertical threshold number of consecutive
%   background pixels) with sums less than or equal to TOL percent.
%
%   If there is a problem at any point an error is returned.  On success res
%   is set to 1, and 0 otherwise.
%
%   See also:  CANDIDATE_CUTS


% CVS INFO %
%%%%%%%%%%%%
% $Id: mark_candidates.m,v 1.1 2005-11-16 18:05:14 scottl Exp $
% 
% REVISION HISTORY:
% $Log: mark_candidates.m,v $
% Revision 1.1  2005-11-16 18:05:14  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%
res = 0;
new_ext = 'cc.';
ht = 20;
vt = 19;
tol = 0;
out_file = '';


% CODE START %
%%%%%%%%%%%%%%
% first do some sanity checking on the arguments passed
error(nargchk(1,5,nargin));

if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
    error('IMG_FILE must contain a single string.');
end

if length(varargin) > 0
    new_ext = varargin{1};
    if length(varargin) > 1
        ht = varargin{2};
        if length(varargin) > 2
            vt = varargin{3};
            if length(varargin) > 3
                tol = varargin{4};
            end
        end
    end
end


% parse file_name to determine name of our output file
dot_idx = regexp(img_file, '\.');
out_file = strcat(img_file(1:dot_idx(length(dot_idx))), new_ext, ...
           img_file(dot_idx(length(dot_idx))+1:length(img_file)));
fprintf('Output filename: %s\n', out_file);


% attempt to open and load the pixel contents of IMG_FILE passed (to 
% ensure it exists)
pixels = imread(img_file);

% get a list of candidate cuts
[tl, tr, bl, br] = candcuts(pixels, ht, vt, tol);
fprintf('top-left list is:\n');
fprintf('(%d,%d)\n', tl');
fprintf('top-right list is:\n');
fprintf('(%d,%d)\n', tr');
fprintf('bot-left list is:\n');
fprintf('(%d,%d)\n', bl');
fprintf('bot-right list is:\n');
fprintf('(%d,%d)\n', br');

% augment the image at each co-ordinate pair
for i=1:size(tl,1)
    pixels = augment(pixels, tl(i,:),'none');
end
for i=1:size(tl,1)
    pixels = augment(pixels, tr(i,:),'left');
end
for i=1:size(bl,1)
    pixels = augment(pixels, bl(i,:),'top');
end
for i=1:size(br,1)
    pixels = augment(pixels, br(i,:),'both');
end

% save our augmented image as the ouptut file
imwrite(pixels, out_file);

res = 1;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pix] = augment(pix, pt, flip)
% AUGMENT  Subfunction that augments pixel values around the 2 element vector
%          pt, to visually mark the pt as a candidate cut.  Currently this
%          involves drawing a 15x15 cross centred at pt.
% pix = mxn matrix of pixel values, like that returned from imread()
% pt = 2 element vector giving x,y co-ords of candidate cut point

x = pt(1);
y = pt(2);
cross = [ 0 0 1 1 1 1 0 0 0 1 1 1 1 1 1;
          0 0 0 1 1 1 0 0 0 1 1 1 1 1 1;
          1 0 0 0 1 1 0 0 0 1 1 1 1 1 1;
          1 1 0 0 0 1 0 0 0 1 1 1 1 1 1;
          1 1 1 0 0 0 0 0 0 1 1 1 1 1 1;
          1 1 1 1 0 0 0 0 0 1 1 1 1 1 1;
          0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
          1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;
          1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;
          1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;
          1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;
          1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;
          1 1 1 1 1 1 0 0 0 1 1 1 1 1 1 ];

if strcmp(flip,'left')
    cross = fliplr(cross);
elseif strcmp(flip,'top')
    cross = flipud(cross);
elseif strcmp(flip,'both')
    cross = flipud(fliplr(cross));
end

le = x-7;
re = x+7;
te = y-7;
be = y+7;

if y <= 7
    %trim top
    cross = cross(9-y:15, :);
    te = 1;
elseif y+7 > size(pix,1)
    %trim bottom
    cross = cross(1:8+(size(pix,1) - y),:);
    be = size(pix,1);
end

if x <= 7
    %trim left
    cross = cross(:, 9-x:15);
    le = 1;
elseif x+7 > size(pix,2)
    %trim right
    cross = cross(:, 1:8+(size(pix,2) - x));
    re = size(pix,2);
end

% put the cross onto the image
pix(te:be, le:re) = cross;
