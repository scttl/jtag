function feats = normalize_feats(feats_in,norm);
%fprintf('Normalizing some features.\n');
%fprintf('Normalizing features.\n');
%fprintf('size(feats_in)=\n');
%disp(size(feats_in));
%fprintf('norm=\n');
%disp(norm);
for i=1:size(feats_in,2);
    feats(:,i) = (feats_in(:,i) + norm.norm_add(i)) / norm.norm_div(i);
end;
