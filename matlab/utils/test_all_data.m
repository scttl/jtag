function res = test_all_data(batchname);

fprintf('For nips:\n');
nips = test_set([batchname '-nips']);
%nips = test_set('2004-07-29-nips-train.knn.mat', ...
%                '2004-07-29-nips-test.knn.mat', ...
%                '2004-07-29-nips-train.lr.mat', ...
%                '2004-07-29-nips-train.memm.mat', ...
%                '2004-07-29-nips-results.mat');

fprintf('For jmlr:\n');
jmlr = test_set([batchname '-jmlr']);
%jmlr = test_set('2004-07-29-jmlr-train.knn.mat', ...
%                '2004-07-29-jmlr-test.knn.mat', ...
%                '2004-07-29-jmlr-train.lr.mat', ...
%                '2004-07-29-jmlr-train.memm.mat', ...
%                '2004-07-29-jmlr-results.mat');

evalstr = ['save ' batchname '-results-all.mat nips jmlr'];
eval(evalstr);
%save all-results-nomarks.mat nips jmlr;

%***********************************
% Subfunction Declarations

%function testres = test_set(f_trn,f_tst,f_ww,f_memm,fname);

function testres = test_set(batchname);

    fprintf('     Loading training data and weights.\n');
    trn = parse_training_data([batchname '-train.knn.mat']);
    tst = parse_training_data([batchname '-test.knn.mat']);
    ww = parse_lr_weights([batchname '-train.lr.mat']);
    memm_w = parse_lr_weights([batchname '-train.memm.mat']);
    fprintf('     Loading successful.\n');

    lr.ww = ww;
    fprintf('     Calculating LR training error.\n');
    [cor,tot,res] = lr_test(trn,ww);
    lr.trn.cor = cor;
    lr.trn.tot = tot;
    lr.trn.res = res;

    fprintf('     Calculation LR test error.\n');
    [cor,tot,res] = lr_test(tst,ww);
    lr.tst.cor = cor;
    lr.tst.tot = tot;
    lr.tst.res = res;
    evalstr = ['save ' batchname '-results-lr.mat lr;'];
    eval(evalstr);
    lr_print_results(lr.tst.res,ww.class_names, ...
                     [batchname '-results-lr-test.csv']);
    lr_print_results(lr.trn.res,ww.class_names, ...
                     [batchname '-results-lr-train.csv']);

    knn = [];
    fprintf('     Calculating KNN training error.\n');
    [cor,tot,res] = knn_test(trn,trn);
    knn.trn.cor = cor;
    knn.trn.tot = tot;
    knn.trn.res = res;
 
    fprintf('     Calculating KNN test error.\n');
    [cor,tot,res] = knn_test(tst,trn);
    knn.tst.cor = cor;
    knn.tst.tot = tot;
    knn.tst.res = res;

    evalstr = ['save ' batchname '-results-knn.mat knn;'];
    eval(evalstr);
    lr_print_results(knn.tst.res,trn.class_names, ...
                     [batchname '-results-knn-test.csv']);
    lr_print_results(knn.trn.res,trn.class_names, ...
                     [batchname '-results-knn-train.csv']);


    memm.ww = memm_w;
    
    fprintf('     Calculating MEMM training error.\n');
    [cor,tot,res,td] = memm_test(trn,memm_w);
    memm.trn.cor = cor;
    memm.trn.tot = tot;
    memm.trn.res = res;
    memm.trn.td = td;
    
    fprintf('     Calculating MEMM test error.\n');
    [cor,tot,res,td] = memm_test(tst,memm_w);
    memm.tst.cor = cor;
    memm.tst.tot = tot;
    memm.tst.res = res;
    memm.tst.td = td;

    evalstr = ['save ' batchname '-results-memm.mat memm;'];
    eval(evalstr);
    lr_print_results(memm.tst.res,memm_w.class_names, ...
                     [batchname '-results-memm-test.csv']);
    lr_print_results(memm.trn.res,memm_w.class_names, ...
                     [batchname '-results-memm-train.csv']);

    testres.lr = lr;
    testres.knn = knn;
    testres.memm = memm;

    fprintf('Saving results...');
    evalstr = ['save ' batchname '-results-all.mat lr knn memm tst trn;'];
    eval(evalstr);

