function [ssum_cor,ssum_tot] = lr_test_all(tstDir,tdFile);

ssum_cor = 0;
ssum_tot = 0;

tstFiles = dir(strcat(tstDir, '/*.jtag'));


for ii = 1:size(tstFiles,1);
  [cor,tot] = knn_test_file(strcat(tstDir,'/',tstFiles(ii).name),tdFile);
  ssum_cor = ssum_cor + cor;
  ssum_tot = ssum_tot + tot;
end;

disp(ssum_cor/ssum_tot);


%jmlr test data dir: '/h/40/klaven/klaven/Journals/TEST_DATA/jmlr/'


%jmlr weights dir: '/h/40/klaven/klaven/Journals/TRAINING_DATA/jmlr.lr.data'



