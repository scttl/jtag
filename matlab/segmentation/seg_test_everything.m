function [nips,jmlr] = seg_test_everything();

%Script to run all segmentation tests.

diary ./seg_test_everything_diary.txt;
diary on;

%Paramater assignments:
nips.trn = ...
    parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');
%nips.trn = ...
%    parse_training_data('./nips-minitd.knn.mat');
nips.tst = ....
    parse_training_data('./results/2004-10-04/2004-10-04-nips-test.knn.mat');
%nips.tst = ...
%    parse_training_data('./nips-minitd2.knn.mat');
nips.xycut.ht = 14;
nips.xycut.vt = 45;
nips.smear.hs = 35;
nips.smear.vs = 14;
nips.voronoi.Td1 = 30;
nips.voronoi.Td2 = 50;
load ./results/ltc3/test3/ltc3-test3-nips-train.lr.mat;
nips.ltc3.ww = savedweightvar;
load ./results/rgs/nips-train-params.rgs.mat;
nips.rgs.params = params;

jmlr.trn = ...
    parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');
%jmlr.trn = ...
%    parse_training_data('./jmlr-minitd.knn.mat');
jmlr.tst = ...
    parse_training_data('./results/2004-10-04/2004-10-04-jmlr-test.knn.mat');
%jmlr.tst = ...
%    parse_training_data('./jmlr-minitd.knn.mat');
jmlr.xycut.ht = 18;
jmlr.xycut.vt = 70;
jmlr.smear.hs = 60;
jmlr.smear.vs = 14;
jmlr.voronoi.Td1 = 30;
jmlr.voronoi.Td2 = 50;
load ./results/ltc3/test3/ltc3-test3-jmlr-train.lr.mat;
jmlr.ltc3.ww = savedweightvar;
load ./results/rgs/jmlr-train-params.rgs.mat;
jmlr.rgs.params = params;

%Now, run the testing.
fprintf('For JMLR:\n');
jmlr = run_all_seg_tests(jmlr);
save SegTestEverythingJmlr.mat jmlr;

fprintf('For NIPS:\n');
nips = run_all_seg_tests(nips);
save SegTestEverythingNips.mat nips;

save SegTestEverythingAll.mat jmlr nips;

diary off;


%---------------------------------------------
function d = run_all_seg_tests(d);

fprintf('    Starting xycuts.\n');
[d.xycut.trn.s1,d.xycut.trn.s2,d.xycut.trn.s3] = ...
    seg_test_all_ways(d.trn,'xycuts',d.xycut.ht,d.xycut.vt);
[d.xycut.tst.s1,d.xycut.tst.s2,d.xycut.tst.s3] = ...
    seg_test_all_ways(d.tst,'xycuts',d.xycut.ht,d.xycut.vt);

fprintf('    Starting smear.\n');
[d.smear.trn.s1,d.smear.trn.s2,d.smear.trn.s3] = ...
    seg_test_all_ways(d.trn,'smear',d.smear.hs,d.smear.vs);
[d.smear.tst.s1,d.smear.tst.s2,d.smear.tst.s3] = ...
    seg_test_all_ways(d.tst,'smear',d.smear.hs,d.smear.vs);

fprintf('    Starting voronoi.\n');
[d.voronoi.trn.s1,d.voronoi.trn.s2,d.voronoi.trn.s3] = ...
    seg_test_all_ways(d.trn,'voronoi',d.voronoi.Td1,d.voronoi.Td2);
[d.voronoi.tst.s1,d.voronoi.tst.s2,d.voronoi.tst.s3] = ...
    seg_test_all_ways(d.tst,'voronoi',d.voronoi.Td1,d.voronoi.Td2);

fprintf('    Starting ltc3.\n');
[d.ltc3.trn.s1,d.ltc3.trn.s2,d.ltc3.trn.s3] = ...
    seg_test_all_ways(d.trn,'ltc3',d.ltc3.ww);
[d.ltc3.tst.s1,d.ltc3.tst.s2,d.ltc3.tst.s3] = ...
    seg_test_all_ways(d.tst,'ltc3',d.ltc3.ww);

fprintf('    Starting rgs.\n');
[d.rgs.trn.s1,d.rgs.trn.s2,d.rgs.trn.s3] = ...
    seg_test_all_ways(d.trn,'rgs',d.rgs.params);
[d.rgs.tst.s1,d.rgs.tst.s2,d.rgs.tst.s3] = ...
    seg_test_all_ways(d.tst,'rgs',d.rgs.params);


