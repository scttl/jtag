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
% $Id: ink_dens_feature.m,v 1.1 2003-07-23 22:26:34 scottl Exp $
% 
% REVISION HISTORY:
% $Log: ink_dens_feature.m,v $
% Revision 1.1  2003-07-23 22:26:34  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

bg = 1;          % default value for background pixels
threshold = .02; % default threshold for subrectangle ink


% first do some argument sanity checking on the arguments passed
error(nargchk(2,3,nargin));

if nargin == 3
    threshold = varargin{1} / 100;
end

p = rect_dens_feature(sr_ink_feature(rect,pixels,threshold), pixels);
