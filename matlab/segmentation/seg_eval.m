function loglikelihood = seg_eval(p,seg_pred,seg_cor,cid);
%
%function loglikelihood = seg_eval(p,seg_pred,seg_cor,cid);
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
    if matched;
        num_cor = num_cor + 1;
    else
        num_wrong = num_wrong + 1;
        %fprintf('No match for l%i t%i r%i b%i\n', seg_cor(i,1), ...
        %        seg_cor(i,2), seg_cor(i,3), seg_cor(i,4));
    end;
end;

loglikelihood = - num_wrong;

return;



%------------------------------------------
%New version: A predicted segment is "correct" if:
%   1. All of the following conditions are met:
%       1.1 It contains one class_id of region
%       1.2 The horizontal projections of contained (or partially
%           contained) regions do not overlap
%       1.3 It does not split any correct region in a columnar manner
cid_map = zeros(size(p));
for i=1:length(cid);
    cid_map(seg_cor(i,2):seg_cor(i,4),seg_cor(i,1):seg_cor(i,3)) = cid(i);
end;
rnum_map = zeros(size(p));
for i=1:size(seg_cor,1);
    rnum_map(seg_cor(i,2):seg_cor(i,4),seg_cor(i,1):seg_cor(i,3)) = i;
end;

well_covered_map = zeros(size(p));

num_cor = 0;
num_wrong = 0;
num_act = size(seg_cor,1);
for i=1:size(seg_pred,1);
    l=seg_pred(i,1); r=seg_pred(i,3); t=seg_pred(i,2); b=seg_pred(i,4);

    cm = cid_map(t:b,l:r); cm = cm(find(cm>0));
    if (max(cm) == min(cm));
        contains_one_class = true;
    else;
        contains_one_class = false;
        %fprintf('Predicted region %i contains multiple classes\n',i);
    end;
    
    rm = rnum_map(t:b,l:r);
    m = max(rm')';
    M = repmat(m,1,size(rm,2));
    if or((rm == M), (rm == 0));
        nooverlaps = true;
    else;
        nooverlaps = false;
        %fprintf('Predicted region %i has overlaps\n',i);
    end;
    
    tmp = rnum_map .* (1 - p);
    in_box = unique(tmp(t:b,l:r));
    if (length(in_box) > 0) && (in_box(1) == 0); in_box(1) = []; end;
    beside_box = unique([tmp(t:b,1:l-1),tmp(t:b,r+1:size(p,2))]);
    if (length(beside_box)>0) && (beside_box(1)==0); beside_box(1)=[]; end;
    if (any(ismember(in_box,beside_box)));
        nocolsplits = false;
        %fprintf('Predicted region %i has column splits\n',i);
    else;
        nocolsplits = true;
    end;
    
    %nocolsplits = true;
    %if (l > 5);
    %    ls1 = rnum_map(t:b,l);
    %    ls2 = rnum_map(t:b,l-5);
    %    if any(and((ls1==ls2),(ls1~=0)));
    %        nocolsplits = false;
    %        fprintf('Predicted region %i has column splits (left)\n',i);
    %    end;
    %end;
    %if (r +5 <= size(rnum_map,2));
    %    rs1 = rnum_map(t:b,r);
    %    rs2 = rnum_map(t:b,r+5);
    %    if any(and((rs1==rs2),(rs1~=0)));
    %        nocolsplits = false;
    %        fprintf('Predicted region %i has column splits (right)\n',i);
    %    end;
    %end;
    
    if (nocolsplits && nooverlaps && contains_one_class);
        num_cor = num_cor + 1;
        well_covered_map(t:b,l:r) = 1 + well_covered_map(t:b,l:r);
        %fprintf('Covering seg %i, (%i:%i, %i:%i)\n', i,t,b,l,r);
    else;
        num_wrong = num_wrong + 1;
    end;
end;
loglikelihood = min(num_cor - num_act,0);

num_errors = 0;
num_good = 0;
%seg_plot(p,seg_pred);
not_covered_map = (well_covered_map ~= 1) .* rnum_map;
not_covered_ink_map = (1 - p) .* not_covered_map;
not_covered_regions = unique(not_covered_ink_map);
%disp(not_covered_regions);

if (length(not_covered_regions) >= 1) && (not_covered_regions(1) == 0);
    not_covered_regions(1) = [];
end;

num_errors = length(not_covered_regions);
loglikelihood = - num_errors;

return;
%--------------------------------------------------------

%loglikelihood = - (sum(abs(c_matched-1))+sum(abs(p_matched-1)) );

%loglikelihood = - (num_wrong) * (size(seg_pred,1) + 0.5);

