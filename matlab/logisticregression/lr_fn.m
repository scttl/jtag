function class_id = lr_fn(class_names, features, jtag_file, in_weights)
% LR_FN    Implements the logistic regression classification algorithm.
%
%   CLASS_ID = LR_FN(CLASS_NAMES, FEATURES, JTAG_FILE, WEIGHTS)  
%   This function runs an
%   implementation of the logistic regression algorithm using the CLASS_NAMES
%   and FEATURES passed.  CLASS_NAMES should be a cell array containing
%   strings representing the names of the classes (and their position the id)
%   like that returned for the class_names field in CREATE_TRAINING_DATA.
%   FEATURES should be a vector of real-valued numbers, like that returned
%   from RUN_ALL_FEATURES.  Finally, WEIGHTS should be either a matrix of
%   real-valued numbers whose entries represent the co-efficient weighting for
%   each (feature,class) pair, or a file path from which these can be loaded
%   using the function parse_lr_weights.  The rows should correspond to
%   features, and the columns classes (the last row contains the biases).  The
%   WEIGHTS should be like those returned in CREATE_LR_WEIGHTS.
%
%   See also:  CREATE_TRAINING_DATA, RUN_ALL_FEATURES, CREATE_LR_WEIGHTS


% CVS INFO %
%%%%%%%%%%%%
% $Id: lr_fn.m,v 1.3 2004-07-29 20:41:56 klaven Exp $
%
% REVISION HISTORY:
% $Log: lr_fn.m,v $
% Revision 1.3  2004-07-29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.2  2004/07/27 22:00:11  klaven
% changed lr_fn so that it accepts the jtag file (or path to it).  This will allow us to extract features based on the file name (such as which page number it is).
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.3  2004/04/22 16:51:03  klaven
% Assorted changes made while testing lr and knn on larger samples
%
% Revision 1.2  2004/01/19 01:44:58  klaven
% Updated the changes made over the last couple of months to the CVS.  I really should have learned how to do this earlier.
%
% Revision 1.1  2003/09/23 14:30:40  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

class_id = nan;


% first do some sanity checking on the arguments passed
error(nargchk(4,4,nargin));

if (ischar(jtag_file) || iscell(jtag_file));
    jt_path = jtag_file;
else;
    jt_path = jtag_file.jtag_file;
end;


% See if we have to load the lr weights from the file
if ischar(in_weights) %& isempty(weights);
    weights = parse_lr_weights(in_weights);
else %if isempty(weights);
    weights = in_weights;
end;

% compare class_names passed with weights.class_names
% also, create index conversion table
indcon = zeros(size(weights.class_names));
for i = 1:size(weights.class_names,2)
    for j = 1:size(class_names,2)
        if strcmp(weights.class_names{i}, class_names{j})
	    indcon(i) = j;
            j = 1;
            break;
        end
    end
    if j == size(class_names,2)
        % weights class not found in class_names list
        error([weights.class_names{i} ' not found in CLASS_NAMES list']);
    end
end

features = normalize_feats(features,weights);

% get the transpose of features
features = features';

[M,N] = size(features);
[M2,C] = size(weights.weights);

logqq = weights.weights'*[features;ones(1,N)];
logpc = logqq - repmat(logsum(logqq,1),C,1);
[DUMMY, tmp_class_id] = max(logpc,[],1);

class_id = zeros(size(tmp_class_id));
for i = 1:size(tmp_class_id,2)
    class_id(i) = indcon(tmp_class_id(i));
end
