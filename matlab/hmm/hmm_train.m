function [T, O] = hmm_train(data, outfile)
% HMM_TRAIN    Estimates values for the transition and observation probability
%              matrices for a 1st order HMM
%
%   [T,O] = HMM_TRAIN(DATA, [OUTFILE])  Attempts to build up an n by n matrix
%   of class transition probabilities (n=number of different labels), and a
%   gaussian struct (mean and covariance matrix) specifying observation (or 
%   emission) probabilities of the feature vectors.  The DATA pased should 
%   either be a struct like that returned from CREATE_TRAINING_DATA, or it can 
%   be a list of files like that passed into CREATE_TRAINING_DATA.  This data 
%   will contain a list of features and selections used to determine appropriate
%   values for the transition and observation probabilites.  The optional 
%   arguments that can be specified include OUTFILE, the path and name of the 
%   file to save the returned parameters.
%
%   O.Mu -> matrix of means (one entry per feature per class)
%   O.Var -> matrix of covariance (one entry per feature per class)
%   
%
%   See Also: GAUSSNB_TRAIN


% CVS INFO %
%%%%%%%%%%%%
% $Id: hmm_train.m,v 1.1 2006-02-19 18:53:58 scottl Exp $
% 
% REVISION HISTORY:
% $Log: hmm_train.m,v $
% Revision 1.1  2006-02-19 18:53:58  scottl
% Initial check-in of hidden markov model classifer
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%
class_names = [];

% first do some argument sanity checking on the argument passed
error(nargchk(1,2,nargin));

if ~ isstruct(data)
    if ~ iscellstr(data)
        error('DATA must either be a list of files or a struct ala CREATE_TD');
    else
        % convert list to training data struct
        data = create_training_data(data);
    end
end

% initialize output struct and fields
c_names = data.class_names;
num_classes = length(c_names);
sop = get_cid('start_of_page');
eop = get_cid('end_of_page');
T = zeros(num_classes);
O = [];

%Sort the elements of each page of the data.
data = mm_sort(data);

%After the elements are sorted, add the sequence label features
data = memm_add_td_label_features(data);

%normalize the training data
norms = find_norms(data);
data = normalize_td(data,norms);

%loop over each page to calculate the class transition counts
for i = 1:data.num_pages;

    order = data.pg{i}.ordered_index;
    for j=2:length(order)
        ii = data.pg{i}.cid(order(j-1));
        jj = data.pg{i}.cid(order(j));
        T(ii,jj) = T(ii,jj) + 1;
    end
end

% now divide by the total number of counts of each column
% distributions (@@@@and add smoothing?)
tots = sum(T);
tots(tots == 0) = 1;  % to prevent dividing by 0 in the next line
T = T ./ repmat(tots,size(T,1),1);

% calculate the gaussian means and variances (this will be applied to the sorted
% data)
[DUMMY, O.Mu, O.Var] = gaussnb_train(data);

if (nargin == 2);
    evalstr = ['save ', outfile, ' T O'];
    eval(evalstr);
end

