function class_id = memm_fn(class_names, features, jtag_file, in_weights);

if (ischar(jtag_file) || iscell(jtag_file));
    jt_path = char(jtag_file);
else;
    jt_path = jtag_file.jtag_file;
    jt_save(jtag_file);
end;

if (ischar(in_weights) || iscell(in_weights));
    ww = parse_lr_weights(char(in_weights));
else;
    ww = in_weights;
end;

td.class_names = class_names;
td.pg_names = {jt_path};
td.num_pages = 1;
pg.features = features;
pg.cid = zeros(1,size(features,1));
td.pg{1} = pg;

td = memm_sort(td);

td = memm_predict_2(td,ww);

cids = td.pg{1}.pred_cid;
labels = td.class_names(cids);
class_id = [];
for i=1:length(labels);
    tmp1 = strcmp(class_names,char(labels(i)));
    tmp2 = find(tmp1);
    if (isempty(tmp2));
        class_id(i) = 0;
    else
        class_id(i) = tmp2(1);
    end;
end;


