function res = test_seg_and_tabel_everything(workdir);

diary test_seg_and_label_everything_diary.txt
diary on;
%Test all segmentation and labelling combinations.

%Paramater assignments:

global seg_method_names;
seg_method_names = {'xycut','smear','voronoi','ltc3','rgs'};
global lab_method_names;
lab_method_names = {'knn','lr','memm','rgs'};

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
nips.knn.td = nips.trn;
nips.lr.ww = ...
    parse_lr_weights('./results/2004-10-04/2004-10-04-nips-train.lr.mat');
nips.memm.ww = ...
    parse_lr_weights('./results/2004-10-04/2004-10-04-nips-train.memm.mat');

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
jmlr.rgs.params = savedweightvar;
jmlr.knn.td = jmlr.trn;
jmlr.lr.ww = ...
    parse_lr_weights('./results/2004-10-04/2004-10-04-jmlr-train.lr.mat');
jmlr.memm.ww = ...
    parse_lr_weights('./results/2004-10-04/2004-10-04-jmlr-train.memm.mat');


fprintf('For NIPS:\n');
nips = run_everything(nips,[workdir '/nips']);
save TestSegAndLabelEverythingNips.mat nips;

fprintf('For JMLR:\n');
jmlr = run_everything(jmlr,[workdir '/jmlr']);
save TestSegAndLabelEverythingJmlr.mat jmlr;

save TestSegAndLabelEverythingAll.mat nips jmlr;

diary off;



function [d,scores] = run_everything(d,workdir);
global seg_method_names;
global lab_method_names;
%Create workdir if it doesn't exist
forcedir(workdir);



%First, for the training data:
td = d.trn;
pred_jt = [];
scores = [];
segs = [];
for i=1:length(seg_method_names);
    for j=1:length(lab_method_names);
        pred_jt(i,j).jts = [];
        for k=1:3;
            scores(i,j,k) = 0;
        end;
    end;
end;
%For each jtag file in the training data
for i=1:length(td.pg);
    fprintf('Training %i of %i.',i,length(td.pg));
    %Load the jtag and the pixels
    jt = jt_load(char(td.pg_names{i}),0);
    pix = imread(jt.img_file);
    %Segment them by each segmentation method
    segs(1).rects = xycut(pix,d.xycut.ht,d.xycut.vt);
    fprintf('.');
    segs(2).rects = smear(pix,d.smear.hs,d.smear.vs);
    fprintf('.');
    segs(3).rects = voronoi1(pix,d.voronoi.Td1,d.voronoi.Td2);
    fprintf('.');
    segs(4).rects = ltc3_cut_file(jt,d.ltc3.ww,pix);
    fprintf('.');
    segs(5).rects = rgs_page(jt,d.rgs.params);
    fprintf('.  segmented.');

    %For each segmentation
    for j=1:length(segs);
        rects = segs(j).rects;
        %Run it through each labelling method, storing the results of each
        %as a jt structure (saving the jt file in workdir)
        [knn,lr,memm,rgs] = predict_labels(jt,segs(j).rects,d, ...
                               [workdir '/train/' char(seg_method_names(j))]);
        fprintf('  predicted.');
        pred_jt(j,1).jts = [pred_jt(j,1).jts; knn];
        pred_jt(j,2).jts = [pred_jt(j,2).jts; lr];
        pred_jt(j,3).jts = [pred_jt(j,3).jts; memm];
        pred_jt(j,4).jts = [pred_jt(j,4).jts; rgs];

        %Call eval_seg_and_label_file, and store the resulting scores.
        for k = 1:size(pred_jt,2);
            [s1,s2,s3]=eval_seg_and_label_file(jt,pred_jt(j,k).jts(end));
            scores(j,k,1) = scores(j,k,1) + s1;
            scores(j,k,2) = scores(j,k,2) + s2;
            scores(j,k,3) = scores(j,k,3) + s3;
        end;
        fprintf('  scored.\n');
    end;
end;
d.scores.trn = scores;
d.pred_jts.trn = pred_jt;



%Second, for the test data:
td = d.tst;
pred_jt = [];
scores = [];
segs = [];
for i=1:length(seg_method_names);
    for j=1:length(lab_method_names);
        pred_jt(i,j).jts = [];
        for k=1:3;
            scores(i,j,k) = 0;
        end;
    end;
end;
%For each jtag file in the training data
for i=1:length(td.pg);
    %Load the jtag and the pixels
    jt = jt_load(char(td.pg_names{i}),0);
    pix = imread(jt.img_file);
    %Segment them by each segmentation method
    segs(1).rects = xycut(pix,d.xycut.ht,d.xycut.vt);
    segs(2).rects = smear(pix,d.smear.hs,d.smear.vs);
    segs(3).rects = voronoi1(pix,d.voronoi.Td1,d.voronoi.Td2);
    segs(4).rects = ltc3_cut_file(jt,d.ltc3.ww,pix);
    segs(5).rects = rgs_page(jt,d.rgs.params);

    %For each segmentation
    for j=1:length(segs);
        rects = segs(j).rects;
        %Run it through each labelling method, storing the results of each
        %as a jt structure (saving the jt file in workdir)
        [knn,lr,memm,rgs] = predict_labels(jt,segs(j).rects,d, ...
                              [workdir '/test/' char(seg_method_names(j))]);
        pred_jt(j,1).jts = [pred_jt(j,1).jts; knn];
        pred_jt(j,2).jts = [pred_jt(j,2).jts; lr];
        pred_jt(j,3).jts = [pred_jt(j,3).jts; memm];
        pred_jt(j,4).jts = [pred_jt(j,4).jts; rgs];

        %Call eval_seg_and_label_file, and store the resulting scores.
        for k = 1:size(pred_jt,2);
            [s1,s2,s3]=eval_seg_and_label_file(jt,pred_jt(j,k).jts(end));
            scores(j,k,1) = scores(j,k,1) + s1;
            scores(j,k,2) = scores(j,k,2) + s2;
            scores(j,k,3) = scores(j,k,3) + s3;
        end;
    end;
end;
d.scores.tst = scores;
d.pred_jts.tst = pred_jt;



function [knn,lr,memm,rgs] = predict_labels(jt,rects,d,workdir);

global class_names;


feats = run_all_features(rects,jt.img_file);
fnames = run_all_features();

forcedir(workdir);
forcedir([workdir '/knn']);
forcedir([workdir '/lr']);
forcedir([workdir '/memm']);
forcedir([workdir '/rgs']);

jt.rects = rects;
jt.class_id = ones(size(rects,1));
jt.class_name = class_names;

jtpath = jt.jtag_file;
slash_idx = regexp(jtpath,'/');
jtname = jtpath(slash_idx(end)+1:end);

%Create a jtag data structure for each labelling algorithm
knn = jt;
knn.jtag_file = [workdir '/knn/' jtname];
knn.jlog_file = [workdir '/knn/' jtname(1:end-4) 'jlog'];
knn.norms = find_norms(d.knn.td);
td_norm = normalize_td(d.knn.td,knn.norms);
knn.class_id = knn_fn(class_names,feats,'null',td_norm);
jt_save(knn);

lr = jt;
lr.jtag_file = [workdir '/lr/' jtname];
lr.jlog_file = [workdir '/lr/' jtname(1:end-4) 'jlog'];
lr.class_id = lr_fn(class_names,feats,'null',d.lr.ww);
jt_save(lr);

memm = jt;
memm.jtag_file = [workdir '/memm/' jtname];
memm.jlog_file = [workdir '/memm/' jtname(1:end-4) 'jlog'];
td.class_names = class_names;
td.num_pages = 1;
td.pg_names = jt.jtag_file;
[td.feat_names,td.feat_normalized] = run_all_features;
td.isSorted = false;
td.pg = {};
td.pg{1}.cid = ones(1,size(rects,1));
td.pg{1}.features = feats;
td.pg{1}.rects = rects;
td = memm_predict_2(td,d.memm.ww);
memm.class_id = td.pg{1}.cid;
jt_save(knn);

rgs = jt;
rgs.jtag_file = [workdir '/rgs/' jtname];
rgs.jlog_file = [workdir '/rgs/' jtname(1:end-4) 'jlog'];
rgs.class_id = rgs_classify_page(jt,d.rgs.params);
jt_save(rgs);



function forcedir(path);
if (path(end) == '/');
    path = path(1:end-1);
end;
idx = regexp(path,'/');
if (length(idx) > 0);
    forcedir(path(1:idx(end)-1));
end;
if (length(path) > 0);
    tmp = dir(path);
    if (length(tmp) == 0);
        cmd = ['mkdir ' path];
        system(cmd);
    end;
end;
