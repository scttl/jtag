function loglikelihood = seg_eval(p,seg_pred,seg_cor);
%
%function loglikelihood = seg_eval(p,seg_pred,seg_cor);
% Loss function for segmentation supervised learning.
%     p is the pixels
%     seg_pred is the predicted segmentation
%     seg_cor is the correct (actual) segmentation
%
% Any predicted/actual pair in which each of the four dimensions
% is within 10 pixels of its counterpart is considered a match.
%
% Loss = num_wrong;
%

num_cor = 0;
num_wrong = 0;
c_matched = zeros(size(seg_cor,1),1);
p_matched = zeros(size(seg_pred,1),1);
for i = 1:size(seg_cor,1);
    matched = false;
    for j = 1:size(seg_pred,1);
        if (max(abs(seg_pred(j,:) - seg_cor(i,:))) < 10);
            matched = true;
            c_matched(i,1) = c_matched(i,1) + 1;
            p_matched(j,1) = p_matched(j,1) + 1;
        end;
    end;
    if matched;
        num_cor = num_cor + 1;
    else
        num_wrong = num_wrong + 1;
        %fprintf('No match for l%i t%i r%i b%i\n', seg_cor(i,1), ...
        %        seg_cor(i,2), seg_cor(i,3), seg_cor(i,4));
    end;
end;

loglikelihood = - num_wrong;

%loglikelihood = - (sum(abs(c_matched-1))+sum(abs(p_matched-1)) );

%loglikelihood = - (num_wrong) * (size(seg_pred,1) + 0.5);

% Try #2: Use each corner as a dimension, and find the "squared error".
