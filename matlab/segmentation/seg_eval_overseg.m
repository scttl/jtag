function [undersegs,segs] = seg_eval_overseg(p,seg_pred,seg_cor);
%
%function [undersegs,segs] = seg_eval_overseg(p,seg_pred,seg_cor);
%
%Counts the number of segments (segs) and undersegmentations (undersegs)
%in seg_pred, evaluated against seg_cor.
%
%An undersegmentation is any predicted segment that is not fully
%covered by a single actual segment.
%

segs = size(seg_pred,1);

rnum_map = zeros(size(p));
for i=1:size(seg_cor,1);
    rnum_map(seg_cor(i,2):seg_cor(i,4),seg_cor(i,1):seg_cor(i,3)) = i;
end;

undersegs = 0;
for i=1:size(seg_pred,1);
    s = seg_pred(i,:);
    submap = rnum_map(s(2):s(4),s(1):s(3));
    rnums = unique(submap);
    rnums = rnums(find(rnums ~= 0));
    if (length(rnums) > 1);
        undersegs = undersegs + 1;
    end;
end;

