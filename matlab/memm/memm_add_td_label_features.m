function td_out = memm_add_label_features(td_in);
%function td_out = memm_add_label_features(td_in);
%
% Adds label features.  
%
% If only td_in is provided, does all the pages using the actual 
% labels.  The label given to item t will be the actual label of
% item (t-1).  An extra region "end_of_page" will be added to 
% each page.
%

if (isfield(td_in,'label_feats_added') && td_in.label_feats_added);
    td_out = td_in;
    fprintf('Label features have already been added.\n');
    return;
end;
    

global class_names;

td_out = td_in;
td_out.pg = [];
td_out.label_feats_added = 1;

for i=1:td_in.num_pages;
    pg = td_in.pg{i};
    pg.cid = get_cid([td_in.class_names(pg.cid), {'end_of_page'}]);
    blankfeat = zeros(1,size(pg.features,2));
    pg.features = [pg.features;blankfeat];
    pg.ordered_index = [pg.ordered_index length(pg.cid)];
    cn = class_names(pg.cid(pg.ordered_index(1:end-1)));
    prevpagelabels = [{'start_of_page'}, cn];
    feats = pg.features(pg.ordered_index,:);
    feats = memm_add_label_features(feats,prevpagelabels);
    pg.features = zeros(size(feats));
    pg.features(pg.ordered_index,:) = feats;
    %pg.features = memm_add_label_features(pg.features, prevpagelabels);

    td_out.pg{i} = pg;
end;

td_out.class_names = class_names;
td_out.feat_names = [td_out.feat_names, {'follows_unknown_class'}, ...
                     strcat('follows_', class_names)];
for i=(length(td_out.feat_normalized)+1):length(td_out.feat_names);
    td_out.feat_normalized(i) = true;
end;

