function norms = find_norms(td);

allfeats = get_all_feats(td);

for i=1:length(td.feat_names);
    if (td.feat_normalized);
        norms.norm_add(i) = 0;
        norms.norm_div(i) = 1;
    else;
        norms.norm_add(i) = -min(allfeats(:,i));
        norms.norm_div(i) = max(allfeats(:,i) + norms.norm_add(i));
        if (norms.norm_div(i) == 0);
            norms.norm_div(i) = 1;
        end;
    end;
end;
