function [correct,total,results] = lr_test_all(tstDir,lr_weights);
%function [correct,total,results] = lr_test_all(tstDir,lr_weights);
%function [correct,total] = lr_test_all(tstDir,lr_weights);
%
%Tests a all .jtag files in a directory using logistic regression, 
%with the weights specified.
%
%tstDir: the location of a directory containing the .jtag files you
%        want to test.
%lr_weights: a parsed lr_weights file, or the path of a
%            lr_weights file.
%correct: The number of correctly classified regions
%total: The number of regions
%results: A matrix of results.  Results(pred,cor) is the
%         number of times ww.classnames(pred) was the
%         predicted value, and ww.classnames(cor) was
%         the correct value.


if ischar(lr_weights);
  ww=parse_lr_weights(lr_weights);
else
  ww=lr_weights;
end;

correct = 0;
total = 0;

results = zeros(length(ww.class_names),length(ww.class_names)+1);

tstFiles = dir(strcat(tstDir, '/*.jtag'));


fprintf('Weights loaded.  Found %i test files\n', length(tstFiles));
for ii = 1:size(tstFiles,1);
  fprintf('File %i: %s...', ii, tstFiles(ii).name);
  [cor,tot,res] = lr_test_file(strcat(tstDir,'/',tstFiles(ii).name),ww);
  correct = correct + cor;
  total = total + tot;
  results = results + res;
  fprintf(' done.  Got %i/%i, for %i/%i so far.\n',cor,tot,correct,total);
end;




