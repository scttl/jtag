function rr = lr_print_results(results,labels,fpath);
%function rr = lr_prin_results(results,labels,fpath);

fid = fopen(fpath,'w');

labels = [labels, {'Other'}];

fprintf(fid,'Column of labels: predicted.     Row of labels: actual.\n');
if (size(results,2) > size(results,1));
    results = results';
elseif (size(results,2) == size(results,1));
    fprintf(fid,'Or maybe the other way around.\n');
end;

for i=1:length(labels);
  fprintf(fid,',%s',labels{i});
end;
fprintf(fid,'\n');

for i=1:size(results,2);
  fprintf(fid,'%s',labels{i});
  for j=1:size(results,1);
    fprintf(fid,',%i',results(j,i));
  end;
  fprintf(fid,'\n');
end;

for j=1:size(results,1);
    fprintf(fid,',');
end;
fprintf(fid,'Total\n');

fprintf(fid, 'Correct');
for j = 1:size(results,2);
    fprintf(fid,',%i', results(j,j));
end;
fprintf(fid,',0');
fprintf(fid,',%i',trace(results));
fprintf(fid,'\n');

fprintf(fid, 'Wrong');
for j = 1:size(results,2);
    fprintf(fid,',%i', (sum(results(j,:)) - results(j,j)));
end;
fprintf(fid,',%i',sum(results(j,:)));
fprintf(fid,',%i', (sum(sum(results)) - trace(results)));
fprintf(fid,'\n');

fprintf(fid, 'Percent');
for j = 1:size(results,2);
    if (sum(results(j,:)) > 0);
        fprintf(fid,',%f', (100 * results(j,j) / sum(results(j,:))));
    else;
        fprintf(fid,',0');
    end;
end;
fprintf(fid,',0');
fprintf(fid,',%f', (100*(trace(results) / sum(sum(results)))));
fprintf(fid,'\n');

fclose(fid);
rr = 0;
