function [s1,s2,s3] = eval_seg_and_label_file(jt_cor, jt_pred, eval_method);

if (nargin < 3) || strcmp(eval_methd,'all');
    s1 = eval_regs_correct(jt_cor,jt_pred);
    s2 = eval_regs_errors(jt_cor,jt_pred);
    s3 = eval_pix_correct(jt_cor,jt_pred);
elseif (strcmp(eval_method,'regs_correct'));
    s1 = eval_regs_correct(jt_cor,jt_pred);
elseif (strcmp(eval_method,'regs_errors'));
    s2 = eval_regs_errors(jt_cor,jt_pred);
elseif (strcmp(eval_method,'pix_correct'));
    s3 = eval_pix_correct(jt_cor,jt_pred);
end;


%----------------------------------------------
%Subfunctions
%----------------------------------------------

function score = eval_regs_correct(jt_cor,jt_pred);
seg_cor = jt_cor.rects;
seg_pred = jt_pred.rects;
cid_cor = get_cid(jt_cor.class_name(jt_cor.class_id));
cid_pred = get_cid(jt_pred.class_name(jt_pred.class_id));

num_cor = 0;
for i = 1:size(seg_cor,1);
    for j = 1:size(seg_pred,1);
        if (cid_cor(i) == cid_pred(j)) &&
           (max(abs(seg_pred(j,:) - seg_cor(i,:))) < 5);
            num_cor = num_cor + 1;
            break;
        end;
    end;
end;
score = length(cid_cor) - num_cor;


function score = eval_regs_errors(jt_cor,jt_pred);
seg_cor = jt_cor.rects;
seg_pred = jt_pred.rects;
cid_cor = get_cid(jt_cor.class_name(jt_cor.class_id));
cid_pred = get_cid(jt_pred.class_name(jt_pred.class_id));

c_matched = zeros(size(seg_cor,1),1);
p_matched = zeros(size(seg_pred,1),1);
for i = 1:size(seg_cor,1);
    matched = false;
    for j = 1:size(seg_pred,1);
        if (cid_cor(i) == cid_pred(j)) &&
           (max(abs(seg_pred(j,:) - seg_cor(i,:))) < 5);
            matched = true;
            c_matched(i,1) = c_matched(i,1) + 1;
            p_matched(j,1) = p_matched(j,1) + 1;
        end;
    end;
end;
%loglikelihood = - (sum(abs(c_matched-1))+sum(abs(p_matched-1)) );

score = - (sum(abs(c_matched-1))+sum(abs(p_matched-1)) );

    

function score = eval_pix_correct(jt_cor,jt_pred);
seg_cor = jt_cor.rects;
seg_pred = jt_pred.rects;
cid_cor = get_cid(jt_cor.class_name(jt_cor.class_id));
cid_pred = get_cid(jt_pred.class_name(jt_pred.class_id));
pix = imread(jt.imgfile);
regmap_pred = zeros(size(pix));
regmap_cor = zeros(size(pix));

for i=1:length(cid_cor);
    r = seg_cor(i,:);
    regmap_cor(r(2):r(4),r(1):r(3)) = cid_cor(i);
end;

for i=1:length(cid_pred);
    r = seg_pred(i,:);
    regmap_pred(r(2):r(4),r(1):r(3)) = cid_pred(i);
end;

score = - length(find(regmap_pred ~= regmap(cor)));


