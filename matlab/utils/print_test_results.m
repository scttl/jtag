function rr = print_test_results(results,labels,fpath);

fid = fopen(fpath,'w');

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

fclose(fid);
rr = 0;
