function feats = normalize_feats(feats_in,norm);
%fprintf('Normalizing some features.\n');
for i=1:size(feats_in,2);
    feats(:,i) = (feats_in(:,i) + norm.norm_add(i)) / norm.norm_div(i);
end;
