%Script to optimize xycut for JMLR and NIPS

jmlr=parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');

nips=parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');

jhs=[10 10 10 11 11 11 12 12 12 13 13 13 14 14 14 15 15 15 ];
jvs=[ 6  7  8  6  7  8  6  7  8  6  7  8  6  7  8  6  7  8 ];

nhs=[ 5  5  5  5  5  6  6  6  6  6  7  7  7  7  7  8  8  8  8  8 ...
      9  9  9  9  9 10 10 10 10 10 ];
nvs=[ 2  3  4  5  6  2  3  4  5  6  2  3  4  5  6  2  3  4  5  6 ...
      2  3  4  5  6  2  3  4  5  6 ];
    
fprintf('Starting JMLR.\n');
[JSegs,JUndersegs] = seg_test_overseg(jmlr,jhs,jvs);

save Overseg_Optimization_jmlr.mat jhs jvs JSegs JUndersegs;

fprintf('-----------------------\n');
fprintf('Starting NIPS.\n');
[NSegs,NUndersegs] = seg_test_overseg(nips,nhs,nvs);

save Overseg_Optimization_nips.mat nhs nvs NSegs NUndersegs;

save Overseg_Optimization_all.mat nhs nvs jhs hvs JSegs JUndersegs NSegs NUndersegs;

