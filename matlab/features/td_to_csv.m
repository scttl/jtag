function res = td_to_csv(td,outfile);

fnum = fopen(outfile,'w');
%fnum = 1;

fnames = td.feat_names;
cnames = td.class_names;

fprintf(fnum,'page,page_num,order,class,class_id');
for i=1:length(fnames);
    fprintf(fnum,',%s',fnames{i});
end;
fprintf(fnum,'\n');

for i=1:length(td.pg);
    fprintf('Page %i\n',i);
    pname = td.pg_names{i};
    pg = td.pg{i};
    for j=1:length(pg.ordered_index);
        k = pg.ordered_index(j);
        fprintf('     Item %i, in order %i\n',j,k);
        fprintf(fnum,'%s,%i,%i,%s,%i',pname,i,j,cnames{pg.cid(k)},pg.cid(k));
        for l=1:size(pg.features,2);
            fprintf(fnum,',%f',pg.features(k,l));
        end;
        fprintf(fnum,'\n');
    end;
end;

fprintf(fnum,'\n');
fclose(fnum);
