function loglikelihood = seg_eval_2(p,seg_pred,seg_cor);
%
%function loglikelihood = seg_eval(p,seg_pred,seg_cor);
% Loss function for segmentation supervised learning.
%     p is the pixels
%     seg_pred is the predicted segmentation
%     seg_cor is the correct (actual) segmentation
%
% Any predicted/actual pair in which each of the four dimensions
% is within 5 pixels of its counterpart is considered a match.
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
        if (max(abs(seg_pred(j,:) - seg_cor(i,:))) < 5);
            matched = true;
            c_matched(i,1) = c_matched(i,1) + 1;
            p_matched(j,1) = p_matched(j,1) + 1;
        end;
    end;
    if ~matched;
        num_wrong = num_wrong + 1;
    end;
end;

for i = 1:size(seg_pred,1);
    matched = false;
    for j=1:size(seg_cor,1);
        if (max(abs(seg_cor(j,:) - seg_pred(i,:))) < 5);
            matched = true;
        end;
    end;
    if ~matched;
        num_wrong = num_wrong + 1;
    end;
end;

loglikelihood = - num_wrong;

