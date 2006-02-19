function M = iso_noise_delete(img_file, varargin)
% ISO_NOISE_DELETE Removes isolated pixel noise from the background of the
%                  image passed.
%
%   M = ISO_NOISE_DELETE(IMG_FILE, {DISTANCE}, {RADIUS}) 
%   Removes isolated pixel noise from the IMG_FILE passed (either the file
%   itself, or its pixel matrix representation.
%
%   This is done by calculating the distance from a given non-background pixel 
%   to its nearest non-background pixel, and removing it if this distance is
%   larger than the DISTANCE threshold passed.  Default is 10 pixels
%   
%   Small clusters of connected pixels (of size RADIUS) can also be deleted,
%   by increasing the value of RADIUS passed.  Default is 1 (i.e. single
%   pixel)
%
%   In all cases, a matrix representation of the image passed is returned 
%   with the noise removed.
%
%   If there is a problem at any point, an error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: iso_noise_delete.m,v 1.1 2006-02-19 18:49:08 scottl Exp $
%
% REVISION HISTORY:
% $Log: iso_noise_delete.m,v $
% Revision 1.1  2006-02-19 18:49:08  scottl
% Initial checkin.
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% default distance and radius (if not passed above)
dist = 1;  % default distance from nearest pixel to be considered isolated
rad = 1;  % default connected pixel radius 


% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));

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
    dist = varargin{1};
    if dist < 1
        error('distance passed must be positive');
    end
    if nargin == 3
        rad = varargin{2};
        if rad < 1
            error('radius passed must be positive');
        end
    end
end

% repeat throwing out noisy pixels until there is no change
Mnew = p;
M = ~Mnew;  %this is done so we can get into the loop the first time
while Mnew ~= M
    fprintf('iterating\n');
    M = Mnew;
    % create a matrix that will hold pixel distances
    % sweep from the top-left point
    dtl = tlsweep(p);
    % sweep from the top-right point
    dtr = fliplr(tlsweep(fliplr(p)));
    % sweep from the bottom-left point
    dbl = flipud(tlsweep(flipud(p)));
    % sweep from the bottom-right point
    dbr = flipud(fliplr(tlsweep(flipud(fliplr(p)))));

    % now take the minimum distance from these four sweeps
    d = min(min(dtl, dtr), min(dbl, dbr));
    % now throw out all the fg pixels whose min distance is larger than dist
    Mnew(Mnew > 0 & d > dist) = d(Mnew > 0 & d > dist) & 0;
end

% now flip the fg and bg values back to that which imread uses
M = ~Mnew;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Out = tlsweep(In)
% TLSWEEP - this subfunction calculates the between pixel distances from the
%           input matrix passed when looking for the nearest pixel that is 
%           above and to the left of the current pixel under examination.
%           The matrix returned gives the value of the distance and is
%           non-zero wherever a non-background pixel (ie non-zero) appears

bg = 0;  % value for background pixels
%first_pixel = [0,0]; % the row and column offset of the first pixel found
first_pixel = true;

Out = zeros(size(In));
T = zeros(size(In));

for r=1:size(In,1)
    for c=1:size(In,2)
        if r == 1
            tdist = inf;
        else
            if In(r-1,c) ~= bg
                tdist = 1;
            elseif c == 1
                tdist = T(r-1,c);
            else
                if In(r-1,c-1) ~= bg
                    tdist = 1;
                else
                    tdist = min(T(r-1,c-1), T(r-1,c));
                end
            end
        end
        if c == 1
            ldist = inf;
        else
            if In(r,c-1) ~= bg
                ldist = 1;
            else
                ldist = T(r,c-1);
            end
        end
        if In(r,c) ~= bg
            if first_pixel
                T(r,c) = inf;
                first_pixel = false;
            else
                %distance is the same as the smallest previous
                T(r,c) = min(ldist,tdist);
            end
        else
            %add one to the previous smallest
            T(r,c) = min(ldist,tdist) + 1;
        end
    end
end

Out(In > 0 & T ~= bg) = T(In > 0 & T~= bg);
