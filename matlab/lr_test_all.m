function [correct,total,results] = lr_test_all(tstDir,lr_weights);

if ischar(lr_weights);
  ww=parse_lr_weights(lr_weights);
else
  ww=lr_weights;
end;

correct = 0;
total = 0;

results = zeros(length(ww.class_names),length(ww.class_names)+1);

tstFiles = dir(strcat(tstDir, '/*.jtag'));


for ii = 1:size(tstFiles,1);
  [cor,tot,res] = lr_test_file(strcat(tstDir,'/',tstFiles(ii).name),ww);
  correct = correct + cor;
  total = total + tot;
  results = results + res;
end;




