function feature_vals = run_all_features(rects, pixels)
% RUN_ALL_FEATURES    Iterates through each feature available on RECT,  building
%                     up a cell array containing all the results.
%
%   RES = RUN_ALL_FEATURES(RECTS, PIXELS)  This function runs through each
%   feature listed, passing the appropriate arguments, collecting the result
%   and adding it to the vector RES which is returned once all features have
%   been completed.
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
% $Id: run_all_features.m,v 1.6 2004-06-08 00:56:50 klaven Exp $
%
% REVISION HISTORY:
% $Log: run_all_features.m,v $
% Revision 1.6  2004-06-08 00:56:50  klaven
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

feature_vals = []; % the vector we will build as we run through features
get_names = false; % set to true to return feature names instead of values.
data = {};         % temp holder for structs returned by features

% first do some sanity checking on the arguments passed
error(nargchk(0,2,nargin));

if nargin == 0
    feature_vals = {};
    get_names = true;
elseif nargin == 1
    error('must pass exactly 2 args or none at all');
else
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
    data = distance_features;
    feature_vals = {data.name};
    data = density_features;
    feature_vals = [feature_vals,{data.name}];

    %data = [data,[density_features.name]];
    %data(1:20) = distance_features;
    %data(21:22) = density_features;
    %for i = 1:length(data)
    %    feature_vals{i} = data{i}.name;
    %end
else
    data = distance_features(rects,pixels);
    feature_vals = reshape([data.val],size(data));
    data = density_features(rects,pixels);
    feature_vals = [feature_vals,reshape([data.val],size(data))];

    %data = [data,density_features(rects,pixels)];
    %for j = 1:length(rects);
    %    for i = 1:length(data);
    %    feature_vals(j,i) = data{i}.val;
    %    end;
    %end;
end;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
