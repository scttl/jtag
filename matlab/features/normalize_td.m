function td = normalize_td(td_in, norm); 

if (isfield(td_in,'already_normalized') && td_in.already_normalized);
    fprintf('ERROR - training data with %i pages is already normalized',td_in.num_pages);
end; 


td = td_in;
td.norm_add = norm.norm_add;
td.norm_div = norm.norm_div;
for pp=1:length(td_in.pg);
    td.pg{pp}.features = normalize_feats(td_in.pg{pp}.features, norm);
end;
td.already_normalized = true;
