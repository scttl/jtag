function [ssum_cor,ssum_tot] = lr_test_all(tstDir,tdFile);

%function [ssum_cor,ssum_tot] = lr_test_all(tstDir,tdFile);
%
%Tests all .jtag files in a directory using K Nearest Neighbours, 
%with the training data stored in tdFile.
%
%tstDir: The directory containing the .jtag files you want to test
%tdFile: The path of a training data file.  Parse this file
%        using the parse_training_data function.
%ssum_cor: The number of correctly classified regions
%ssum_tot: The number of regions

ssum_cor = 0;
ssum_tot = 0;

tstFiles = dir(strcat(tstDir, '/*.jtag'));

for ii = 1:size(tstFiles,1);
  [cor,tot] = knn_test_file(strcat(tstDir,'/',tstFiles(ii).name),tdFile);
  ssum_cor = ssum_cor + cor;
  ssum_tot = ssum_tot + tot;
end;


