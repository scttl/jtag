function [ssum_cor,ssum_tot] = lr_test_all(tstDir,wFile);

ssum_cor = 0; 
ssum_tot = 0; 

tstFiles = dir(strcat(tstDir, '/*.jtag'));


for ii = 1:size(tstFiles,1); 
  [cor,tot] = lr_test_file(strcat(tstDir,'/',tstFiles(ii).name),wFile); 
  ssum_cor = ssum_cor + cor; 
  ssum_tot = ssum_tot + tot; 
end; 

disp(ssum_cor/ssum_tot);
 

%jmlr test data dir: '/h/40/klaven/klaven/Journals/TEST_DATA/jmlr/'


%jmlr weights dir: '/h/40/klaven/klaven/Journals/TRAINING_DATA/jmlr.lr.data'



