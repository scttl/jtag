function res = memm_test_all_data;

fprintf('For nips:\n');
nips = test_set('./features/nips-train-nomarks.knn.data', ...
                './features/nips-test-nomarks.knn.data', ...
                './memm/memm-nips.memm.mat', ...
                './memm/memm-nips-results.mat');

fprintf('For jmlr:\n');
jmlr = test_set('./features/jmlr-train-nomarks.knn.data', ...
                './features/jmlr-test-nomarks.knn.data', ...
                './memm/memm-jmlr.memm.mat', ...
                './memm/memm-jmlr-results.mat');

save ./memm/memm-all-results.mat nips jmlr;

%***********************************
% Subfunction Declarations

function res = test_set(f_trn,f_tst,f_ww,fname);

    fprintf('     Loading test data and weights.\n');
    trn = parse_training_data(f_trn);
    tst = parse_training_data(f_tst);
    ww = parse_lr_weights(f_ww);

    fprintf('     Calculating MEMM training error.\n');
    [cor,tot,res,data] = memm_test(trn,ww);
    res.trn.cor = cor;
    res.trn.tot = tot;
    res.trn.res = res;
    res.trn.data = data;

    fprintf('     Calculating MEMM test error.\n');
    [cor,tot,res,data] = memm_test(tst,ww);
    res.tst.cor = cor;
    res.tst.tot = tot;
    res.tst.res = res;
    res.tst.data = data;


    fprintf('Saving results...');
    evalstr = ['save ' fname ' res;'];
    eval(evalstr);

