%Script to optimize xycut for JMLR and NIPS

jmlr=parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');

nips=parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');

hs=[ 5  5  5  5  5  6  6  6  6  6  7  7  7  7  7 ...
     8  8  8  8  8  9  9  9  9  9 10 10 10 10 10 ...
    11 11 11 11 11 12 12 12 12 12 13 13 13 13 13 ...
    14 14 14 14 14 15 15 15 15 15 ];
vs=[ 1  2  3  4  5  1  2  3  4  5  1  2  3  4  5 ...
     1  2  3  4  5  1  2  3  4  5  1  2  3  4  5 ...
     1  2  3  4  5  1  2  3  4  5  1  2  3  4  5 ...
     1  2  3  4  5  1  2  3  4  5 ];
    
fprintf('Starting JMLR.\n');
[JSegs,JUndersegs] = seg_test_overseg(jmlr,hs,vs);

save Overseg_Optimization_jmlr.mat hs vs JSegs JUndersegs;

fprintf('-----------------------\n');
fprintf('Starting NIPS.\n');
[NSegs,NUndersegs] = seg_test_overseg(nips,hs,vs);

save Overseg_Optimization_nips.mat hs vs NSegs NUndersegs;

save Overseg_Optimization_all.mat hs vs JSegs JUndersegs NSegs NUndersegs;

