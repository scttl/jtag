%Script to optimize xycut for JMLR and NIPS

jmlr = parse_training_data('./results/nosnap/nosnap-jmlr-train.knn.mat');

nips = parse_training_data('./results/nosnap/nosnap-nips-train.knn.mat');

ht=[30 30 30 30 30 30 30 30 35 35 35 35 35 35 35 35 ...
    40 40 40 40 40 40 40 40 45 45 45 45 45 45 45 45 50 50 50 50 50 50 50 50 ...
    55 55 55 55 55 55 55 55 60 60 60 60 60 60 60 60 65 65 65 65 65 65 65 65 ...
    70 70 70 70 70 70 70 70 75 75 75 75 75 75 75 75 80 80 80 80 80 80 80 80];
vt=[14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28 ...
    14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28 ...
    14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28 ...
    14 16 18 20 22 24 26 28 14 16 18 20 22 24 26 28];

[JScores,JAllScores] = seg_test_xycut(jmlr,ht,vt);

save XYCut_Optimization_jmlr.mat ht vt JScores JAllScores;

[NScores,NAllScores] = seg_test_xycut(nips,ht,vt);

save XYCut_Optimization_nips.mat ht vt NScores NAllScores;

save XYCut_Optimization.mat ht vt JScores JAllScores NScores NAllScores;

