function [feature_vals,f_norm]=run_all_features(rects, pix_file,use_in,donames)
% RUN_ALL_FEATURES    Iterates through each feature available on RECT,  building
%                     up a cell array containing all the results.
%
%   [FEATURE_VALS,F_NORM] = RUN_ALL_FEATURES(RECTS, PIX_FILE, USE_IN, DONAMES)  
%   This function runs through each
%   feature listed, passing the appropriate arguments, collecting the result
%   and adding it to the vector which is returned once all features have
%   been completed.
%
%   F_NORM is a boolean indicating if the feature is "naturally normalized",
%   with values between 0 and 1, and a mean expected to be near 0.5.
%
%   If called without any arguments, then feature_vals returned is a cell
%   array containing the names of each feature instead of feature data.
%
%   If there is a problem at any point an error is returned to the caller.
%
%   As new features are added and removed, they should be updated in this
%   function and not called directly or from anywhere else in the code.


% CVS INFO %
%%%%%%%%%%%%
% $Id: run_all_features.m,v 1.7 2004-12-04 22:12:22 klaven Exp $
%
% REVISION HISTORY:
% $Log: run_all_features.m,v $
% Revision 1.7  2004-12-04 22:12:22  klaven
% *** empty log message ***
%
% Revision 1.6  2004/11/12 22:28:19  klaven
% Minor debugging.
%
% Revision 1.5  2004/08/16 22:38:10  klaven
% Functions that extract features now work with a bunch of boolean variables to turn the features off and on.
%
% Revision 1.4  2004/08/04 20:51:19  klaven
% Assorted debugging has been done.  As of this version, I was able to train and test all methods successfully.  I have not yet tried using them all in the jtag software yet.
%
% Revision 1.3  2004/07/29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.2  2004/07/27 21:57:58  klaven
% run_all_features now takes the path to the image file, rather than the pixels.  This will let us parse the file name to determine which page it is, and how many pages there are in the journal.
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.7  2004/06/14 16:25:19  klaven
% Completed the marks-based features.  Still need to test them to make sure they are behaving.
%
% Revision 1.6  2004/06/08 00:56:50  klaven
% Debugged new distance and density features.  Added a script to make training simpler.  Added a script to print out output.
%
% Revision 1.5  2004/06/01 21:38:21  klaven
% Updated the feature extraction methods to take all the rectangles at once, rather than work one at a time.  This allows for the extraction of features that use relations between rectangles.
%
% Revision 1.4  2004/06/01 19:24:34  klaven
% Assorted minor changes.  About to re-organize.
%
% Revision 1.3  2004/05/14 17:21:32  klaven
% Working on features for classification.  Realized that the distance features need some work.  Specifically, I think they are not being normalized properly, and several of them are redundant.
%
% Revision 1.2  2003/08/26 21:38:20  scottl
% Included 4 new features that calculate the distance from subrectangle edges
% to associated page edges.
%
% Revision 1.1  2003/08/18 15:00:01  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

global use;

use_feats = use;
if (nargin >= 3);
    use_feats = use_in;
end;

feature_vals = []; % the vector we will build as we run through features
f_norm = [];
get_names = false; % set to true to return feature names instead of values.
data = {};         % temp holder for structs returned by features

if (nargin == 0) || ((nargin >= 4) && (donames));
    feature_vals = {};
    get_names = true;
elseif nargin == 1
    error('must pass 2 or 3 args or none at all');
else

    pixels = imread(char(pix_file));

    [r, c] = size(pixels);
    if ndims(rects) > 2 | size(rects,2) ~= 4;
        error('Each RECT must have exactly 4 elements.');
    else
        for rr = 1:size(rects,1);
            if min(rects(:,1)) < 1 | min(rects(:,2)) < 1 | ...
               max(rects(:,3)) > c | max(rects(:,4)) > r;
                error('RECT passed exceeds PIXEL boundaries');
            end;
        end
    end;
end

% start running through features.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==========> Edit below as more features are added/removed <========== %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if get_names
    data = distance_features(use_feats);
    feature_vals = {data.name};
    f_norm = [data.norm];
    if (use_feats.dens);
        data = density_features;
        feature_vals = [feature_vals,{data.name}];
        f_norm = [f_norm [data.norm]];
    end;
    if (use_feats.pnum)
        data = pnum_features;
        feature_vals = [feature_vals,{data.name}];
        f_norm = [f_norm [data.norm]];
    end;
    if (use_feats.mark);
        data = marks_features;
        feature_vals = [feature_vals,{data.name}];
        f_norm = [f_norm, [data.norm]];
    end;
    if (use_feats.ocr);
        data = ocr_features(use_feats);
        feature_vals = [feature_vals,{data.name}];
        f_norm = [f_norm, [data.norm]];
    end;
else
    data = distance_features(use_feats,rects,pixels);
    feature_vals = reshape([data.val],size(data));
    f_norm = [data.norm];
    if (use_feats.dens);
        data = density_features(rects,pixels);
        feature_vals = [feature_vals,reshape([data.val],size(data))];
        f_norm = [f_norm [data.norm]];
    end;
    if (use_feats.pnum);
        data = pnum_features(rects,pixels,pix_file);
        feature_vals = [feature_vals,reshape([data.val],size(data))];
        f_norm = [f_norm [data.norm]];
    end;
    if (use_feats.mark);
        data = marks_features(rects,pixels);
        feature_vals = [feature_vals,reshape([data.val],size(data))];
        f_norm = [f_norm [data.norm]];
    end;
    if (use_feats.ocr);
        data = ocr_features(use_feats,rects,pixels);
        feature_vals = [feature_vals,reshape([data.val],size(data))];
        f_norm = [f_norm [data.norm]];
    end;
end;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
