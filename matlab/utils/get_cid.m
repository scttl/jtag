function cid = get_cid(labels);

global class_names;

if (~iscell(labels));
    labels = {labels};
end;
cid = [];
for i=1:length(labels);
    tmp1 = strcmp(class_names,char(labels(i)));
    tmp2 = find(tmp1);
    if (isempty(tmp2));
        cid(i) = 0;
    else
        cid(i) = tmp2(1);
    end;
end;
