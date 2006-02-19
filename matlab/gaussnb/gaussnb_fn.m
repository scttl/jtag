function class_id = gaussnb_fn(features, Py, Mu, Var)
% GAUSSNB_FN    Implements a naive Bayes Gaussian Classifier
%
%   CLASS_ID = GAUSSNB_FN(FEATURES, PY, MU, VAR))  
%   This function runs an implementation of a naive bayes gaussian classifier
%   on the FEATURE(S) passed (one feature per column -- mutiple rows are seen
%   as separate instances and classified separately)).  PY should be a vector
%   of prior probabilities (one entry for each class).  MU should be a matrix
%   of means, one for each class of each feature.  Each column should
%   represent a features mean, and each row represents a particular class.  
%   Similarly VAR should be a matrix of variances, one for each class of each
%   feature.  Under naive bayes (these are independent), so we can calculate
%   a classes mean or variance by taking the product.
%
%   See also:  GAUSSNB_TRAIN


% CVS INFO %
%%%%%%%%%%%%
% $Id: gaussnb_fn.m,v 1.1 2006-02-19 18:51:34 scottl Exp $
%
% REVISION HISTORY:
% $Log: gaussnb_fn.m,v $
% Revision 1.1  2006-02-19 18:51:34  scottl
% Initial checkin of the gaussian naive bayes classifier
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%

class_id = [];


% first do some sanity checking on the arguments passed
error(nargchk(4,4,nargin));

% want to find the class y that maximizes P(y|x).  We use bayes rule and
% the parameters passed to compute this
num_classes = length(Py);
num_feats = size(features, 2);
num_cases = size(features, 1);

for i=1:num_cases
    % calculate P(y|x) for all classes y, then take the max as the final 
    % prediction
    preds = zeros(num_classes,1);
    for j=1:num_classes
        %nz = Var(j,:) ~= 0;
        if Mu(j,1) == NaN
            % this class didn't appear once in the training set, output NaN
            preds(j) = NaN;
        else 
            %preds(j) = Py(j) * prod((1 ./ sqrt(2 * pi * Var(j,nz))) .* ...
            %           exp(-(features(i,nz) - Mu(j,nz)).^2 ./ (2 * Var(j,nz))));
            preds(j) = log(Py(j)) + sum(log(1 ./ sqrt(2 * pi * Var(j,:))) + ...
                       (-(features(i,:) - Mu(j,:)).^2 ./ (2 * Var(j,:))));
            %preds(j) = log(Py(j)) + sum(log(1 ./ sqrt(2 * pi * Var(j,nz))) + ...
            %           (-(features(i,nz) - Mu(j,nz)).^2 ./ (2 * Var(j,nz))));
        end
    end
    [DUMMY, class_id(i)] = max(preds);
end
