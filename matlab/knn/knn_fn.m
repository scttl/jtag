function class_id = knn_fn(class_names, features, in_data, varargin)
% KNN_FN    Implements the k-nearest neighbour classification algorithm.
%
%   CLASS_ID = KNN_FN(CLASS_NAMES, FEATURES, IN_DATA, {K})  This function runs
%   an implementation of the k-nearest neighbours algorithm using the training
%   DATA, CLASS_NAMES,  and FEATURES passed.  DATA should either be a string
%   specifying the path to a valid  ASCII training data file, or it can be
%   structured according to that returned by CREATE_TRAINING_DATA.  CLASS_NAMES
%   should be a cell array containing strings representing the class names to
%   be used for classification (one per column).  FEATURES should be a vector
%   of real-valued numbers, like that returned from RUN_ALL_FEATURES.  The
%   CLASS_NAMES passed are checked to ensure that they are the same as those
%   found in the training data, and if some are in the training data and not
%   there, then an error is returned.
%
%   See also:  CREATE_TRAINING_DATA, RUN_ALL_FEATURES


% CVS INFO %
%%%%%%%%%%%%
% $Id: knn_fn.m,v 1.1 2004-06-19 00:27:27 klaven Exp $
% 
% REVISION HISTORY:
% $Log: knn_fn.m,v $
% Revision 1.1  2004-06-19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.5  2004/04/22 16:51:03  klaven
% Assorted changes made while testing lr and knn on larger samples
%
% Revision 1.4  2004/01/19 01:44:57  klaven
% Updated the changes made over the last couple of months to the CVS.  I really should have learned how to do this earlier.
%
% Revision 1.3  2003/09/19 18:19:15  scottl
% Made data a static (persistent) variable, thus drastically reducing running
% times over multiple calls.
%
% Revision 1.2  2003/09/19 15:28:51  scottl
% Updated to get training data as an extra argument.  Checks to ensure
% class_names passed much up to those in the training data etc.
%
% Revision 1.1  2003/08/22 18:14:18  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

k = 1;  % default number of nearest neighbours to consider if k not passd as
        % an arg above.

distances = [];  % will hold the top k nearest distances as they are computed
names = {};        % will hold the associated class names for the k nearest
                   % distances

max_dist = inf;  % distance computed must be less than this to be eligible for
                 % consideration as one of k-nearset
num_elems = 0;  % number of training data elements considered thus far.

class_id = nan;


persistent data;  % so we don't have to recalculate data after each call


% first do some sanity checking on the arguments passed
error(nargchk(3,4,nargin));

if nargin == 4
    k = varargin{1};
end
%fprintf('Value of K is %i\n',k);

% see if we have to load the training data from file
if ischar(in_data) & isempty(data)
    data = parse_training_data(in_data);
elseif isempty(data)
    data = in_data;
end

if ~isfield(data, 'num_pages') | data.num_pages <= 0 | ~isfield(data, 'pg') ...
    | size(features,2) ~= size(data.pg{1}.features,2)
    error('DATA is an invalid struct');
elseif k <= 0
    error('k specified must be positive!');
end

% ensure that each training data class name is found in the list of
% class_names passed.
for i = 1:size(data.class_names,2)
    for j = 1:size(class_names,2)
        if strcmp(data.class_names{i}, class_names{j})
            j = 1;
            break;
        end
    end
    if j == size(class_names,2)
        % training data class not found in class_names list
        error(strcat(data.class_names{i}, ' not found in CLASS_NAMES list'));
    end
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
	        %add this item to the end of the list
		%fprintf('Sticking element on end of list.\n');
		%fprintf('Before: length(names)=%i,pos=%i,num_elems=%i,k=%i.\n',length(names),pos,num_elems,k);
                distances(pos) = dist;
                names{pos} = data.class_names{data.pg{i}.cid(j)};
                if pos == k
                    max_dist = dist;
		end
            elseif num_elems < k
                % add the new element, and shift the rest down by 1
		%fprintf('Inserting element into non-full list.\n');
		%fprintf('Before: length(names)=%i,pos=%i,num_elems=%i,k=%i.\n',length(names),pos,num_elems,k);
		names(pos+1:num_elems+1) = names(pos:num_elems);
		names{pos} = data.class_names{data.pg{i}.cid(j)};
		distances(pos+1:num_elems+1) = distances(pos:num_elems);
		distances(pos) = dist;
                %distances = [distances(1:pos-1), dist, distances(pos:end)];
                %names = {names(1:pos-1), ...
                %         data.class_names{data.pg{i}.cid(j)}, names(pos:end)};
            else
                % shift every element at pos down 1, to allow room for the new
                % element (and remove the last element)
		%fprintf('Inserting element into full list.\n');
		%fprintf('Before: length(names)=%i,pos=%i,num_elems=%i,k=%i.\n',length(names),pos,num_elems,k);
		%disp(names{pos+1:end});
		names(pos+1:end) = names(pos:end-1);
		names{pos} = data.class_names{data.pg{i}.cid(j)};
		distances(pos+1:end) = distances(pos:end-1);
		distances(pos) = dist;

		%if (pos > 1)
		%  dd2 = [distances(1:pos-1),dist];
		%  nn2 = {names(1:pos-1),data.class_names{data.pg{i}.cid(j)}};
		%else
		%  dd2 = [dist];
		%  nn2 = {data.class_names{data.pg{i}.cid(j)}};
		%end
		%distances = [dd2,distances(pos:end-1)];
		%names = {nn2,names{pos:end-1}};

                %distances = [distances(1:pos-1), dist, distances(pos:end-1)];
                %names = {names(1:pos-1), ...
                %         data.class_names{data.pg{i}.cid(j)}, names(pos:end-1)};
                max_dist = distances(end);
            end
	    num_elems = num_elems + 1;
	    %fprintf('After: length(names)=%i,pos=%i,num_elems=%i,k=%i,names:\n',length(names),pos,num_elems,k);
	    %disp(names);
	    %fprintf('\n');
        end

        % num_elems = num_elems + 1;
    end
end

% now determine the majority class_id (from our input list of class_names),
% and output it
max_count = 1;
% added by Kevin:
%disp('Displaying names on the next line');
%disp(names);

names = sort(names);
curr_name = names{1};
curr_count = 1;
class_name = curr_name;

for i = 2:length(names)
    if strcmp(names{i}, curr_name)
        curr_count = curr_count + 1;
        if curr_count > max_count
            max_count = curr_count;
            class_name = curr_name;
        end
    else
        curr_name = names{i};
        curr_count = 1;
    end
end

% find the class_id for our majority name
for i = 1:length(class_names)
    if strcmp(class_name, class_names{i})
        class_id = i;
        break;
    end
end


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
