function w = create_lr_weights(data, sigma, maxevals)
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
% $Id: create_lr_weights.m,v 1.6 2004-06-18 21:58:30 klaven Exp $
% 
% REVISION HISTORY:
% $Log: create_lr_weights.m,v $
% Revision 1.6  2004-06-18 21:58:30  klaven
% Added a few more items to what is stored in the lr_weights.
%
% Revision 1.5  2004/06/14 20:20:06  klaven
% Changed the load and save routines for lr weights to be more general, allowing me to add more fields to the weights data structure.  Also added a record of the log likelihood progress to the weights data structure.
%
% Revision 1.4  2004/06/09 19:20:17  klaven
% Started working on marks-based features.
%
% Revision 1.3  2004/04/22 16:51:03  klaven
% Assorted changes made while testing lr and knn on larger samples
%
% Revision 1.2  2004/01/19 01:44:57  klaven
% Updated the changes made over the last couple of months to the CVS.  I really should have learned how to do this earlier.
%
% Revision 1.1  2003/09/22 20:50:04  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%



% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));
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

% initialize output struct and fields
w.class_names = data.class_names;
w.weights = [];
w.feature_names = data.feat_names;

% cc is the list of all selections class id's
cc = [];
% ff is the list of all selections feature values
ff = [];
for i = 1:data.num_pages
    cc = [cc; data.pg{i}.cid];
    ff = [ff, data.pg{i}.features'];
end

C = max(cc(:));
[M,N] = size(ff);

[weightmatrix,llprogress,iterations] = ...
     minimize(sqrt(sigma)*randn((M+1)*C,1),'mefun',maxevals,cc,ff,sigma);

w.loglikelihoods = llprogress;
w.weights = reshape(weightmatrix(:),M+1,C);
