function p = ink_dens_feature(rect, pixels, varargin)
% RECT_DENS_FEATURE   Returns the total percentage of non-background pixels
%                     inside the ink threshold subrectangle of RECT passed.
%
%  P = INK_DENS_FEATURE(RECT, PAGE, {THRESH})  This feature simply counts all 
%  the pixels within the subrectangle inside RECT that meets THRESH percentage
%  of non-background pxiels, and returns the percentage of which that are 'ink'
%  inside the subrectangle.  If THRESH is not passed, it defaults to 2 percent


% CVS INFO %
%%%%%%%%%%%%
% $Id: ink_dens_feature.m,v 1.2 2003-07-24 19:28:30 scottl Exp $
% 
% REVISION HISTORY:
% $Log: ink_dens_feature.m,v $
% Revision 1.2  2003-07-24 19:28:30  scottl
% Added checking to threshold passed.
%
% Revision 1.1  2003/07/23 22:26:34  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

threshold = .02; % default threshold for subrectangle ink


% first do some argument sanity checking on the arguments passed
error(nargchk(2,3,nargin));

if nargin == 3
    if varargin{1} < 0 | varargin{1} > 1
        error('THRESH passed must be a percentage (between 0 and 1)');
    end
    threshold = varargin{1};
end

p = rect_dens_feature(sr_ink_feature(rect,pixels,threshold), pixels);
