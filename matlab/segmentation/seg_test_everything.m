%Script to run all segmentation tests.

%Paramater assignments:
nips.trn = ...
    parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');
nips.tst = ....
    parse_training_data('./results/2004-10-04/2004-10-04-nips-test.knn.mat');
nips.xycut.ht = 0;
nips.xycut.vt = 0;
nips.smear.hs = 0;
nips.smear.vs = 0;
nips.voronoi.Td1 = 0;
nips.voronoi.Td2 = 0;
load ./results/ltc3/test3/ltc3-test3-nips-train.lr.mat;
nips.ltc3.ww = savedweightvar;
load ./results/rgs/;
nips.rgs.params = savedweightvar;

jmlr.trn = ...
    parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');
jmlr.tst = ...
    parse_training_data('./results/2004-10-04/2004-10-04-jmlr-test.knn.mat');
jmlr.xycut.ht = 0;
jmlr.xycut.vt = 0;
jmlr.smear.hs = 0;
jmlr.smear.vs = 0;
jmlr.voronoi.Td1 = 0;
jmlr.voronoi.Td2 = 0;
load ./results/ltc3/test3/ltc3-test3-jmlr-train.lr.mat;
jmlr.ltc3.ww = savedweightvar;
load ./results/rgs/;
jmlr.rgs.params = savedweightvar;

%Now, run the testing.

jmlr = run_all_seg_tests(jmlr);
save SegTestEverythingJmlr.m jmlr;

nips = run_all_seg_test(nips);
save SegTestEverythingNips.m nips;

save SegTestEverythingAll.m jmlr nips;


%---------------------------------------------
function d = run_all_seg_tests(d);

[d.xycut.trn.s1,d.xycut.trn.s2,d.xycut.trn.s3] = ...
    seg_test_all_ways(d.trn,'xycuts',d.xycut.ht,d.xycut.vt);
[d.xycut.tst.s1,d.xycut.tst.s2,d.xycut.tst.s3] = ...
    seg_test_all_ways(d.tst,'xycuts',d.xycut.ht,d.xycut.vt);

[d.smear.trn.s1,d.smear.trn.s2,d.smear.trn.s3] = ...
    seg_test_all_ways(d.trn,'smear',d.smear.hs,d.smear.vs);
[d.smear.tst.s1,d.smear.tst.s2,d.smear.tst.s3] = ...
    seg_test_all_ways(d.tst,'smear',d.smear.hs,d.smear.vs);

[d.voronoi.trn.s1,d.voronoi.trn.s2,d.voronoi.trn.s3] = ...
    seg_test_all_ways(d.trn,'voronoi',d.voronoi.Td1,d.voronoi.Td2);
[d.voronoi.tst.s1,d.voronoi.tst.s2,d.voronoi.tst.s3] = ...
    seg_test_all_ways(d.tst,'voronoi',d.voronoi.Td1,d.voronoi.Td2);

[d.ltc3.trn.s1,d.ltc3.trn.s2,d.ltc3.trn.s3] = ...
    seg_test_all_ways(d.trn,'ltc3',d.ltc3.ww);
[d.ltc3.tst.s1,d.ltc3.tst.s2,d.ltc3.tst.s3] = ...
    seg_test_all_ways(d.tst,'ltc3',d.ltc3.ww);

[d.rgs.trn.s1,d.rgs.trn.s2,d.rgs.trn.s3] = ...
    seg_test_all_ways(d.trn,'rgs',d.rgs.params);
[d.rgs.tst.s1,d.rgs.tst.s2,d.rgs.tst.s3] = ...
    seg_test_all_ways(d.tst,'rgs',d.rgs.params);


