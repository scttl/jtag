function td = rgs_create_td(td,savepath);
%
%function td = rgs_create_td(td,savepath);
%
%Takes normal training data, and prepares it for rgs.  Basically involves
%making sure the correct feature set was used, and then filtering it to
%include only the appropriate features.
%
%Also makes sure the cids are correct as per the global list.
%

if (ischar(td));
    td = parse_training_data(td);
end;

if (length(td.feat_names) ~= 59);
    error('ERROR - incorrect feature set used: must have exactly 59 feats.\n');
end;

global class_names;
use_feats = rgs_feats_to_use();

for i=1:length(td.pg);
    pg = td.pg{i};
    cn = td.class_names(pg.cid);
    cid = get_cid(cn);
    pg.cid = cid;
    pg.features = pg.features(:,use_feats);
    td.pg{i} = pg;
end;

td.feat_names = td.feat_names(use_feats);
td.feat_normalized = td.feat_normalized(use_feats);
td.is_gaus = rgs_gaus_feats();
td.is_bool = rgs_bool_feats();


if (nargin >= 2);
    dump_training_data(td,savepath);
end;


