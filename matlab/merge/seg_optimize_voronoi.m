%Script to optimize Voronoi for JMLR and NIPS

jmlr=parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');

nips=parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');

Td1=[30 30 30 30 30 30];

Td2=[ 5 10 15 20 25 30];


[JScores,JAllScores] = seg_test_voronoi(jmlr,Td1,Td2);

save Voronoi_Optimization_jmlr.mat Td1 Td2 JScores JAllScores;

[NScores,NAllScores] = seg_test_voronoi(nips,Td1,Td2);

save Voronoi_Optimization_nips.mat Td1 Td2 NScores NAllScores;

save Voronoi_Optimization.mat Td1 Td2 JScores JAllScores NScores NAllScores;

