function [left, top, right, bottom] = ink_outer_ws_feature(rect, pixels, ...
                                                            varargin)
% INK_OUTER_WS_FEATURE   Returns the distance from the edges of the ink 
%                        threshold subrectangle of RECT passed, out to the 
%                        nearest amounts of substantial ink on each of the 4 
%                        sides outside the subrectangle.
%
%  [L, T, R, B] = INK_OUTER_WS_FEATURE(RECT, PAGE, {SR_THRESH, OUT_THRESH})  
%  This feature returns a 4 element row vector containing the pixel distance 
%  to the left, top, right, and bottom areas of substantial non-background ink 
%  inside PAGE.  Distance is measure from the subrectangle of RECT that
%  contains atleast SR_THRESH percent ink (or 2 if not specified).
%  Substantial output is determined by the percentage OUT_THRESH passed, and 
%  defaults to 2 if not specified.  Note that if there is only whitespace 
%  between a side of the subrectangle and the edge of the page, the distance 
%  returned for that side is the distance to the edge of the PAGE.


% CVS INFO %
%%%%%%%%%%%%
% $Id: ink_outer_ws_feature.m,v 1.1 2003-07-23 22:29:22 scottl Exp $
% 
% REVISION HISTORY:
% $Log: ink_outer_ws_feature.m,v $
% Revision 1.1  2003-07-23 22:29:22  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

sr_threshold  = .02;  % default threshold to use for the subrectangle of RECT
out_threshold = .02;  % default threshold to use for external whitespace calc.
bg = 1;               % default value for background pixels


% first do some argument sanity checking on the arguments passed
error(nargchk(2,4,nargin));

if nargin >= 3
    if varargin{1} < 0 | varargin{1} > 100
        error('SR_THRESH passed must be a percentage (between 0 and 100)');
    else
        sr_threshold = varargin{1} / 100;
    end

    if nargin == 4
        if varargin{2} < 0 | varargin{2} > 100
            error('OUT_THRESH passed must be a percentage (between 0 and 100)');
        else
            out_threshold = varargin{2} / 100;
        end
    end
end

[left, top, right, bottom] = rect_outer_ws_feature(...
            sr_ink_feature(rect, pixels, sr_threshold), pixels, out_threshold);
