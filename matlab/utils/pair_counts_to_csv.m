function paircounts = pair_counts_to_csv(td, outfile);

global class_names;

fid = fopen(outfile,'w');



paircounts = zeros(length(class_names));

for pp=1:length(td.pg);
    pg = td.pg{pp};
    for c1 = 1:(length(pg.cid)-1);
        paircounts(pg.cid(c1),pg.cid(c1+1)) = ...
            paircounts(pg.cid(c1),pg.cid(c1+1)) + 1;
    end;
end;

for i=1:length(class_names);
    fprintf(fid,',%s',char(class_names(i)));
end;
fprintf(fid,',Total\n');

for i=1:length(class_names);
    fprintf(fid,'%s',char(class_names(i)));
    for j=1:length(class_names);
        fprintf(fid,',%i', paircounts(i,j));
    end;
    fprintf(fid,',%i\n',sum(paircounts(i,:)));
end;

fprintf(fid,'Total');
for j=1:length(class_names);
    fprintf(fid,',%i',sum(paircounts(:,j)));
end;
fprintf(fid,',%i',sum(sum(paircounts)));

fclose(fid);

