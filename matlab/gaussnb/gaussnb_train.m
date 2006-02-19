function [Py, Mu, Var] = gaussnb_train(data, smoothing, outfile)
% GAUSSNB_TRAIN    Estimates values for the priors, class means, and class
%                  covariance matrices for use in a gaussian naive bayes 
%                  classifier.
%
%   [Py, Mu, Cov] = GAUSSNB_TRAIN(DATA, [SMOOTHING, OUTFILE])  Attempts 
%   to build up a vector of smoothed class priors (Py), per feature class means 
%   (Mu), and per class covariance matrices (Cov) for use in a gaussian 
%   naive bayes classifier.  The DATA pased should either be a struct like that 
%   returned from CREATE_TRAINING_DATA, or it can be a list of files like that 
%   passed into CREATE_TRAINING_DATA.  This data will contain a list of features
%   and selections used to determine the means and covariances.  The optional 
%   arguments that can be specified include SMOOTHING, the number of pseudo 
%   counts to add to each class prior (defaults to 1 i.e. Laplacian smoothing), 
%   and OUTFILE, the path and name of the file to save the returned parameters.


% CVS INFO %
%%%%%%%%%%%%
% $Id: gaussnb_train.m,v 1.1 2006-02-19 18:51:34 scottl Exp $
% 
% REVISION HISTORY:
% $Log: gaussnb_train.m,v $
% Revision 1.1  2006-02-19 18:51:34  scottl
% Initial checkin of the gaussian naive bayes classifier
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% first do some argument sanity checking on the argument passed
error(nargchk(1,3,nargin));
if(nargin < 2) smoothing = 1; end  %laplace smoothing if alpha value not passed

if ~ isstruct(data)
    if ~ iscellstr(data)
        error('DATA must either be a list of files or a struct ala CREATE_TD');
    else
        % convert list to training data struct
        data = create_training_data(data);
    end
end

% now initialize our output parameters
num_classes = length(data.class_names);
num_feats = length(data.feat_names);
Py = zeros(num_classes, 1);
Mu = zeros(num_classes, num_feats);
Var = zeros(num_classes, num_feats);

%@@normalize the training data
norms = find_norms(data);
data = normalize_td(data,norms);

% create a large matrix corresponding to all features over all segments
% in all pages, and an associated class label vector over all segments
[F,C] = get_all_features(data);


% this is the smoothed denominator used in calculating the class prior values
den = (length(C) + (num_classes * smoothing));

% loop to calculate values specific to each class
for i=1:num_classes

    % determine the class priors by counting the number of times a class appears
    % and adding pseudo-counts (smoothing) to the total
    Py(i) = (sum(C == i) + smoothing) / den;

    % determine the means for each feature of this class (note these are just
    % the sample means, since they maximize the likelihood for this model)

    % determine the variances for each feature of this class (again these are
    % just the sample variances, since they maximize the likelihood for this
    % model).  We can do this since in naive bayes, we only want the diagonals
    % of the covariance matrix of each class (so we use a single matrix to
    % represent this info compactly).

    fc = F(C == i, :);
    if length(fc) ~= 0
        Mu(i,:) = mean(fc);
        Var(i,:) = var(fc) + (1 / length(fc));
        %Var(i,:) = var(fc) + eps;   %smoothing to ensure matrix invertible
    else
        %no training data exists for these cases.
        Mu(i,:) = NaN;
        Var(i,:) = NaN;
    end
end

% if outfile passed, save the parameters to file as well
if (nargin == 3);
    evalstr = ['save ', outfile, ' Py Mu Var'];
    eval(evalstr);
end
