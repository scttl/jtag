function td_out = update_td_class_names(td_in);
%
% function td_out = update_td_class_names(td_in);
%
% Updates the class_names in td_in to match the global
% class_names.

global class_names;

if (iscell(td_in) | ischar(td_in));
    td = parse_training_data(char(td_in));
else
    td = td_in;
end;

td_out = td;
td_out.pg = [];

for i=1:length(td.pg);
    pg = td.pg{i};
    pg.cid = get_cid(td.class_names(pg.cid));
    td_out.pg{i} = pg;
end;

td_out.class_names = class_names;

if (iscell(td_in) | ischar(td_in));
    fpath = char(td_in);
    dot_idx = regexp(fpath, '\.');
    fpath = [fpath(1:dot_idx(end)) 'mat'];
    dump_training_data(td_out,fpath);
end;

