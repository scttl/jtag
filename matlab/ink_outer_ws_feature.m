function dists = ink_outer_ws_feature(rect, pixels, varargin)
% INK_OUTER_WS_FEATURE   Returns the distance from the edges of the ink 
%                        threshold subrectangle of RECT passed, out to the 
%                        nearest amounts of substantial ink on each of the 4 
%                        sides outside the subrectangle.
%
%  DISTS = INK_OUTER_WS_FEATURE(RECT, PAGE, {SR_THRESH, OUT_THRESH})  
%  This feature returns a 4 element row vector containing the pixel distance 
%  to the left, top, right, and bottom areas of substantial non-background ink 
%  inside PAGE.  Distance is measured from the subrectangle of RECT that
%  contains atleast SR_THRESH percent ink (or 2 percent if not specified).
%  Substantial output is determined by the percentage OUT_THRESH passed, and 
%  defaults to 2 percent if not specified.  Note that if there is only 
%  whitespace between a side of the subrectangle and the edge of the page, the 
%  distance returned for that side is the distance to the edge of the PAGE.
%
%  See also RECT_OUTER_WS_FEATURE


% CVS INFO %
%%%%%%%%%%%%
% $Id: ink_outer_ws_feature.m,v 1.2 2003-07-24 19:54:51 scottl Exp $
% 
% REVISION HISTORY:
% $Log: ink_outer_ws_feature.m,v $
% Revision 1.2  2003-07-24 19:54:51  scottl
% Changed checks on thresholds to 0 and 1 (not 0 and 100).  Updated comments.
%
% Revision 1.1  2003/07/23 22:29:22  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

sr_threshold  = .02;  % default threshold to use for the subrectangle of RECT
out_threshold = .02;  % default threshold to use for external whitespace calc.


% first do some argument sanity checking on the arguments passed
error(nargchk(2,4,nargin));

if nargin >= 3
    if varargin{1} < 0 | varargin{1} > 1
        error('SR_THRESH passed must be a percentage (between 0 and 1)');
    else
        sr_threshold = varargin{1};
    end

    if nargin == 4
        if varargin{2} < 0 | varargin{2} > 1
            error('OUT_THRESH passed must be a percentage (between 0 and 1)');
        else
            out_threshold = varargin{2};
        end
    end
end

dists = rect_outer_ws_feature(sr_ink_feature(rect, pixels, sr_threshold), ...
                                             pixels, out_threshold);
