function res = ltc_test_all_td(path_to_td,batchname);

fprintf('For nips:\n');
nips = test_set([path_to_td '-nips'], [batchname '-nips']);

fprintf('For jmlr:\n');
jmlr = test_set([path_to_td, '-jmlr'], [batchname '-jmlr']);

evalstr = ['save ' batchname '-results-all.mat nips jmlr'];
eval(evalstr);



%***********************************
% Subfunction Declarations

%function testres = test_set(f_trn,f_tst,f_ww,f_memm,fname);

function testres = test_set(path_to_td, batchname);

    fprintf('     Loading training data and weights.\n');
    trn = parse_training_data([path_to_td '-train.knn.mat']);
    tst = parse_training_data([path_to_td '-test.knn.mat']);
    ww = parse_lr_weights([batchname '-train.lr.mat']);
    fprintf('     Loading successful.\n');

    testres.ww = ww;
    fprintf('     Calculating LR training error.\n');
    [score,allsegs] = seg_test_ltc(trn,ww);
    testres.trn.score = score;
    testres.trn.allsegs = allsegs;

    fprintf('     Calculation LR test error.\n');
    [score,allsegs] = seg_test_ltc(tst,ww);
    testres.tst.score = score;
    testres.tst.allsegs = allsegs;

    evalstr = ['save ' batchname '-results-lr.mat testres;'];
    eval(evalstr);

%function td = ltc_parse_training_data(fpath);
%% New version of save routine stores s in a .mat file.
%if (strcmp(fpath(end-3:end), '.mat'));
%    evalstr = ['load ' fpath ';'];
%    eval(evalstr);
%    td = samples;
%    return;
%else;
%    fprintf('ERROR - invalid path for training data.\n');
%    td = [];
%end;
%
