function res = run_all_features(rect, pixels) 
% RUN_ALL_FEATURES    Iterates through each feature available on RECT,  building
%                     up a cell array containing all the results.
%
%   RES = RUN_ALL_FEATURES(RECT, PIXELS)  This function runs through each
%   feature listed, passing the appropriate arguments, collecting the result 
%   and adding it to the vector RES which is returned once all features have 
%   been completed.
%
%   If called without any arguments, then RES returned is a cell array 
%   containing the names of each feature instead of feature data.
%
%   If there is a problem at any point an error is returned to the caller.
%
%   As new features are added and removed, they should be updated in this
%   function and not called directly or from anywhere else in the code.


% CVS INFO %
%%%%%%%%%%%%
% $Id: run_all_features.m,v 1.3 2004-05-14 17:21:32 klaven Exp $
% 
% REVISION HISTORY:
% $Log: run_all_features.m,v $
% Revision 1.3  2004-05-14 17:21:32  klaven
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

res = [];          % the vector we will build as we run through features
get_names = false; % set to true to return feature names instead of values.
data = {};         % temp holder for structs returned by features

% first do some sanity checking on the arguments passed
error(nargchk(0,2,nargin));

if nargin == 0
    res = {};
    get_names = true;
elseif nargin == 1
    error('must pass exactly 2 args or none at all');
else
    [r, c] = size(pixels);
    if ndims(rect) > 2 | size(rect) ~= 4
        error('RECT must have exactly 4 elements.');
    elseif rect(1) < 1 | rect(2) < 1 | rect(3) > c | rect(4) > r
        error('RECT passed exceeds PIXEL boundaries');
    end
end

% start running through features.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ==========> Edit below as more features are added/removed <========== %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if get_names
    data(1:20) = distance_features;
    data(21:26) = density_features;
    for i = 1:length(data)
        res{i} = data{i}.name;
    end
else
    data(1:20) = distance_features(rect,pixels);
    data(21:26) = density_features(rect,pixels);
    for i = 1:length(data)
        res = [res, data{i}.val];
    end
end



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
