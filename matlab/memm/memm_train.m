function w = memm_train(data, sigma, maxevals, outfile)
%
% function w = memm_train(data, sigma, maxevals, outfile)
%
%
%

% CREATE_LR_WEIGHTS    Builds up a struct containing coefficient weights for
%                      use in a logistical regression classifier.
%
%   W = CREATE_LR_WEIGHTS(DATA, [SIGMA, ITERATIONS])  Attempts to build up and
%   optomize a set of coefficient weights for use in a logistic regression
%   classifier.  The DATA pased should either be a struct like that returned
%   from CREATE_TRAINING_DATA, or it can be a list of files like that passed
%   into CREATE_TRAINING_DATA.  This data will contain a list of features and
%   selections used to determine the weights.  The optional arguments that can
%   be specified include SIGMA, the inverse variance of the gaussian weight
%   prior (defaults to 1e-3), and ITERATIONS which specifies the maximum
%   number of evaluations performed during optomization (defaults to 1e8). 
%   The struct w returned has the following structure:
%
%     w.class_names -> cell array whose entries represent the string name of
%                      the class associated with that entry number.
%     w.weights -> MxN matrix of floating point numbers, where each M (row)
%                  represents a class (size(M) == size(w.class_names)), and
%                  each of the N columns corresponds to a weight value 
%                  (coefficient) for that feature.


% CVS INFO %
%%%%%%%%%%%%
% $Id: memm_train.m,v 1.4 2004-07-29 20:41:57 klaven Exp $
% 
% REVISION HISTORY:
% $Log: memm_train.m,v $
% Revision 1.4  2004-07-29 20:41:57  klaven
% Training data is now normalized if required.
%
% Revision 1.3  2004/07/27 22:01:27  klaven
% The new function memm_fn can be used with the jtag software.  Made changes to several other files to accomodate this.
%
% Revision 1.2  2004/07/22 15:55:55  klaven
% MEMM is working correctly as of this version.
%
% Revision 1.1  2004/07/16 20:38:48  klaven
% First version of MEMM (Maximum Entropy Markov Model) learning.  In this version, the class label of the previous region is used as a feature during training and classification.  This is done using a binary feature for each possible class label, which is true if the previous region was labelled that class, and false otherwise.
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%



% first do some argument sanity checking on the argument passed
error(nargchk(1,4,nargin));
if(nargin < 2) sigma = 1e-3; end
if(nargin < 3) maxevals = 1e4; end

if ~ isstruct(data)
    if ~ iscellstr(data)
        error('DATA must either be a list of files or a struct ala CREATE_TD');
    else
        % convert list to training data struct
        data = create_training_data(data);
    end
end

%Sort the elements of each page of the data.
data = memm_sort(data);

%After the elements are sorted, add the labels.
data = memm_add_td_label_features(data);

% initialize output struct and fields
w.class_names = data.class_names;
w.weights = [];
w.feature_names = data.feat_names;

norms = find_norms(data);
data = normalize_td(data,norms);
w.norm_add = data.norm_add;
w.norm_div = data.norm_div;

% cc is the list of all selections class id's
cc = [];
% ff is the list of all selections feature values
ff = [];
for i = 1:data.num_pages;
    cc = [cc; data.pg{i}.cid(data.pg{i}.ordered_index)'];
    %pagelabels = data.class_names(data.pg{i}.cid(data.pg{i}.ordered_index));
    %pagelabels(2:end) = pagelabels(1:end-1);
    %pagelabels(1) = {'start_of_page'};
    pagefeats1 = data.pg{i}.features(data.pg{i}.ordered_index,:);
    %pagefeats2 = [];
    %for j = 1:size(pagefeats1,1);
    %    pagefeats2 = [pagefeats2; ...
    %                  memm_add_label_features(pagefeats1(j,:), pagelabels(j))];
    %end;
    ff = [ff, pagefeats1'];
end


C = max(cc(:));
[M,N] = size(ff);

[weightmatrix,llprogress,iterations] = ...
     minimize(sqrt(sigma)*randn((M+1)*C,1),'mefun',maxevals,cc,ff,sigma);

w.loglikelihoods = llprogress;
w.weights = reshape(weightmatrix(:),M+1,C);

if (nargin == 4);
    dump_lr_weights(w,outfile);
end;

