function loglikelihood = seg_eval(p,seg_pred,seg_cor);
%
%function loglikelihood = seg_eval(p,seg_pred,seg_cor);
% Loss function for segmentation supervised learning.
%     p is the pixels
%     seg_pred is the predicted segmentation
%     seg_cor is the correct (actual) segmentation
%
%
% First attempt: Each actual segment that does not have a
% predicted segment matching all 4 parameters within 10
% pixels is considered an error.
%
% Loss = num_errors * num_pred / (num_cor^2)
%

num_cor = 0;
num_wrong = 0;
for i = 1:size(seg_cor,1);
    matched = false;
    for j = 1:size(seg_pred,1);
        if (max(abs(seg_pred(j,:) - seg_cor(i,:))) < 10);
            matched = true;
        end;
    end;
    if matched;
        num_cor = num_cor + 1;
    else
        num_wrong = num_wrong + 1;
        fprintf('No match for l%i t%i r%i b%i\n', seg_cor(i,1), ...
                seg_cor(i,2), seg_cor(i,3), seg_cor(i,4));
    end;
end;

loglikelihood = - (num_wrong) * (size(seg_pred,1) + 0.5);

% Try #2: Use each corner as a dimension, and find the "squared error".
