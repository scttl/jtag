function class_id = knn_fn(data, features, varargin)
% KNN_FN    Implements the k-nearest neighbour classification algorithm.
%
%   CLASS_ID = KNN_FN(DATA, FEATURES, {K})  This function runs an implementation
%   of the k-nearest neighbours algorithm using the training DATA and FEATURES
%   passed.  DATA should be structured according to that returned by
%   CREATE_TRAINING_DATA and FEATURES should be a vector of real-valued
%   numbers, like that returned from RUN_ALL_FEATURES
%
%   See also:  CREATE_TRAINING_DATA, RUN_ALL_FEATURES


% CVS INFO %
%%%%%%%%%%%%
% $Id: knn_fn.m,v 1.1 2003-08-22 18:14:18 scottl Exp $
% 
% REVISION HISTORY:
% $Log: knn_fn.m,v $
% Revision 1.1  2003-08-22 18:14:18  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

k = 1;  % default number of nearest neighbours to consider if k not passd as 
        % an arg above.

distances = [];  % will hold the top k nearest distances as they are computed
ids = [];        % will hold the associated id's for the k nearest distances

max_dist = inf;  % distance computed must be less than this to be eligible for
                 % consideration as one of k-nearset
num_elems = 0;  % number of training data elements considered thus far.

class_id = nan;



% first do some sanity checking on the arguments passed
error(nargchk(2,3,nargin));

if nargin == 3
    k = varargin{1};
end

if ~isfield(data, 'num_pages') | data.num_pages <= 0 | ~isfield(data, 'pg') ...
    | size(features,2) ~= size(data.pg{1}.features,2)
    error('DATA is an invalid struct');
elseif k <= 0
    error('k specified must be positive!');
%elseif data.num_pages < k --> not num_pages, num_selections!
%    error('not enough training data present to do computation');
end


% loop through each training data element, calculating the euclidian distance
% and potentially adding it to the top k
for i = 1:data.num_pages
    for j = 1:size(data.pg{i}.features, 1)

        dist = sqrt(sum((data.pg{i}.features(j,:) - features).^2));

        if dist < max_dist
            % add this element to the top k in the appropriate position.
            pos = 1;
            while pos < k & pos <= num_elems & dist >= distances(pos)
                pos = pos + 1;
            end

            if (pos > num_elems & pos <= k) | pos == k
                distances(pos) = dist;
                ids(pos) = data.pg{i}.cid(j);
                if pos == k
                    max_dist = dist;
                end
            elseif num_elems < k
                % add the new element, and shift the rest down by 1
                distances = [distances(1:pos-1), dist, distances(pos:end)];
                ids = [ids(1:pos-1), data.pg{i}.cid(j), ids(pos:end)];
            else
                % shift every element at pos down 1, to allow room for the new
                % element (and remove the last element)
                distances = [distances(1:pos-1), dist, distances(pos:end-1)];
                ids = [ids(1:pos-1), data.pg{i}.cid(j), ids(pos:end-1)];
                max_dist = distances(end);
            end
        end

        num_elems = num_elems + 1;
    end
end

% now determine the majority class_id, and output it
max_count = 1;
ids = sort(ids);
curr_id = ids(1);
curr_count = 1;
class_id = curr_id;

for i = 2:length(ids)
    if ids(i) == curr_id
        curr_count = curr_count + 1;
        if curr_count > max_count
            max_count = curr_count;
            class_id = curr_id;
        end
    else
        curr_id = ids(i);
        curr_count = 1;
    end
end






% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
