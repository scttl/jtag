function [F,C] = get_all_features(data)
% GET_ALL_FEATURES  Creates a matrix of all features of all pages, and a
%                   vector of the corresponding class id's
%
%   [F,C] = GET_ALL_FEATURES(DATA)  Builds a matrix of all features from all 
%   pages in the data passed, one feature per column, and one segment per row.
%   Also builds a vector of class id's corresponding to each segment.  The
%   DATA passed should either be a struct like that returned from
%   CREATE_TRAINING_DATA, or it can be a list of file like that passed into
%   CREATE_TRAININD_DATA.  If the data is sorted (i.e. the boolean isSorted
%   field exists and is true in the data struct), then the features and class
%   id's are returned in sorted (i.e. page reading) order.
%
%   See Also:  CREATE_TRAINING_DATA


% CVS INFO %
%%%%%%%%%%%%
% $Id: get_all_features.m,v 1.1 2006-02-19 18:40:18 scottl Exp $
%
% REVISION HISTORY:
% $Log: get_all_features.m,v $
% Revision 1.1  2006-02-19 18:40:18  scottl
% Initial checkin.  Used to be called get_all_feats
%
%

% LOCAL VARS %
%%%%%%%%%%%%%%
order = [];  %this will hold the order of regions on a given page
F = [];      % the feature matrix we will return
C = [];      % the corresponding class id vector

% first do some argument sanity checking on the argument passed
error(nargchk(1,1,nargin));

%load the data if its not loaded already
if ~ isstruct(data)
    if ~ iscellstr(data)
        error('DATA must either be a list of files or a struct ala CREATE_TD');
    else
        % convert list to training data struct
        data = create_training_data(data);
    end
end

% simply loop over each page, adding each entry to the matrix and vector
if (isfield(data, 'isSorted') && data.isSorted)  %sorted, return in order
    for i = 1:length(data.pg);
        order = data.pg{i}.ordered_index;
        F = [F;data.pg{i}.features(order,:)];
        C = [C,data.pg{i}.cid(order)];
    end
else  % not sorted, just get the features and cid's as-is
    for i = 1:length(data.pg);
        F = [F;data.pg{i}.features];
        C = [C,data.pg{i}.cid];
    end
end
