%Script to optimize Voronoi for JMLR and NIPS

jmlr = parse_training_data('./results/nosnap/nosnap-jmlr-train.knn.mat');

nips = parse_training_data('./results/nosnap/nosnap-nips-train.knn.mat');

Td1=[8  8  8  8  9  9  9  9 ...
     10 10 10 10 11 11 11 11];
Td2=[3  4  5  6  3  4  5  6 ...
      3  4  5  6  3  4  5  6];
     

[JScores,JAllScores] = seg_test_voronoi(jmlr,Td1,Td2);

save Voronoi_Optimization_jmlr.mat Td1 Td2 JScores JAllScores;

[NScores,NAllScores] = seg_test_voronoi(nips,Td1,Td2);

save Voronoi_Optimization_nips.mat Td1 Td2 NScores NAllScores;

save Voronoi_Optimization.mat Td1 Td2 JScores JAllScores NScores NAllScores;

