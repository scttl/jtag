function res = td_to_csv(td,outfile,td_norm);

if (ischar(td));
    td = parse_training_data(td);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Normalize td
if (nargin >= 3);
    if (ischar(td_norm));
        td_norm = parse_training_data(td_norm);
    end;
    norms = find_norms(td_norm);
    td = normalize_td(td,norms);
end;


fnum = fopen(outfile,'w');
%fnum = 1;

fnames = td.feat_names;
cnames = td.class_names;

td = memm_sort(td);

fprintf(fnum,'page,page_num,order,class,class_id,left,top,right,bottom');
for i=1:length(fnames);
    fprintf(fnum,',%s',fnames{i});
end;
fprintf(fnum,'\n');

for i=1:length(td.pg);
    %fprintf('Page %i\n',i);
    pname = td.pg_names{i};
    pg = td.pg{i};
    if (~all((sort(pg.ordered_index) == sort(1:size(pg.features,1)))));
        fprintf('ERROR - ordered_index does not cover all features.');
    end;
    for j=1:length(pg.ordered_index);
        k = pg.ordered_index(j);
        %fprintf('     Item %i, in order %i\n',j,k);
        fprintf(fnum,'%s,%i,%i,%s,%i,',pname,i,j,cnames{pg.cid(k)},pg.cid(k));
        fprintf(fnum,'%i,%i,%i,%i',pg.rects(j,1),pg.rects(j,2), ...
                                   pg.rects(j,3),pg.rects(j,4));
        for l=1:size(pg.features,2);
            fprintf(fnum,',%f',pg.features(k,l));
        end;
        fprintf(fnum,'\n');
    end;
end;
res = 1;
fprintf(fnum,'\n');
fclose(fnum);
