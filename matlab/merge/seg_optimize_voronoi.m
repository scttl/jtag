%Script to optimize Voronoi for JMLR and NIPS

jmlr=parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');

nips=parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');

%Td1=[10 10 10 10 10 10];

%Td2=[20 30 40 50 60 70];


Td1=[25 30 35 40 25 30 35 40 25 30 35 40 25 30 35 40];
Td2=[50 50 50 50 55 55 55 55 60 60 60 60 70 70 70 70];


[JScores,JAllScores] = seg_test_voronoi(jmlr,Td1,Td2);

save Voronoi_Optimization2_jmlr.mat Td1 Td2 JScores JAllScores;

[NScores,NAllScores] = seg_test_voronoi(nips,Td1,Td2);

save Voronoi_Optimization2_nips.mat Td1 Td2 NScores NAllScores;

save Voronoi_Optimization2.mat Td1 Td2 JScores JAllScores NScores NAllScores;

