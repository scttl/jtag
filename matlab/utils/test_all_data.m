function res = test_all_data;

fprintf('For nips:\n');
nips = test_set('nips-train-nomarks.knn.data', ...
                'nips-test-nomarks.knn.data', ...
                'nips-train-nomarks.lr.mat', ...
                'nips-results-nomarks.mat');

fprintf('For jmlr:\n');
jmlr = test_set('jmlr-train-nomarks.knn.data', ...
                'jmlr-test-nomarks.knn.data', ...
                'jmlr-train-nomarks.lr.mat', ...
                'jmlr-results-nomarks.mat');

save all-results-nomarks.mat nips jmlr;

%***********************************
% Subfunction Declarations

function res = test_set(f_trn,f_tst,f_ww,fname);

    fprintf('     Loading training data and weights.\n');
    trn = parse_training_data(f_trn);
    tst = parse_training_data(f_tst);
    ww = parse_lr_weights(f_ww);

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

    res.lr = lr;
    res.knn = knn;

    fprintf('Saving results...');
    evalstr = ['save ' fname ' lr knn;'];
    eval(evalstr);

