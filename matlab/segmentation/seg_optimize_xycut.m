%Script to optimize xycut for JMLR

jmlr = parse_training_data('./features/jmlr-train-nomarks.knn.mat');

nips = parse_training_data('./features/nips-train-nomarks.knn.mat');

ht=[25 25 25 25 25 25 25 25 30 30 30 30 30 30 30 30 35 35 35 35 35 35 35 35 ...
    40 40 40 40 40 40 40 40 45 45 45 45 45 45 45 45 50 50 50 50 50 50 50 50 ...
    55 55 55 55 55 55 55 55 60 60 60 60 60 60 60 60];
vt=[16 18 20 22 24 26 28 30 16 18 20 22 24 26 28 30 16 18 20 22 24 26 28 30 ...
    16 18 20 22 24 26 28 30 16 18 20 22 24 26 28 30 16 18 20 22 24 26 28 30 ...
    16 18 20 22 24 26 28 30 16 18 20 22 24 26 28 30];

[JScores,JAllScores] = seg_test_xycut(jmlr,ht,vt);

save XYCut_Optimization_jmlr.mat ht vt JScores JAllScores;

[NScores,NAllScores] = seg_test_xycut(nips,ht,vt);

save XYCut_Optimization_nips.mat ht vt NScores NAllScores;

save XYCut_Optimization.mat ht vt JScores JAllScores NScores NAllScores;

