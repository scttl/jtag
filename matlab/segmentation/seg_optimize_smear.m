%Script to optimize smear for JMLR and NIPS

jmlr = parse_training_data('./results/nosnap/nosnap-jmlr-train.knn.mat');

nips = parse_training_data('./results/nosnap/nosnap-nips-train.knn.mat');
hs=[25 25 25 25 25 25 25 25 30 30 30 30 30 30 30 30 35 35 35 35 35 35 35 35 ...
    40 40 40 40 40 40 40 40 45 45 45 45 45 45 45 45 50 50 50 50 50 50 50 50 ...
    55 55 55 55 55 55 55 55 60 60 60 60 60 60 60 60 65 65 65 65 65 65 65 65 ...
    70 70 70 70 70 70 70 70 75 75 75 75 75 75 75 75 80 80 80 80 80 80 80 80];
vs=[ 8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22 ...
     8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22 ...
     8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22 ...
     8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22  8 10 12 14 16 18 20 22];

[JScores,JAllScores] = seg_test_smear(jmlr,hs,vs);

save Smear_Optimization2_jmlr.mat hs vs JScores JAllScores;

[NScores,NAllScores] = seg_test_smear(nips,hs,vs);

save Smear_Optimization2_nips.mat hs vs NScores NAllScores;

save Smear_Optimization2.mat hs vs JScores JAllScores NScores NAllScores;

