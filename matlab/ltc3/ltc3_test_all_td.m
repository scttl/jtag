function res = ltc3_test_all_td(batchname,path_to_td);

if (nargin < 2);
    path_to_td = './results/withmarks/marks';
end;

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
    [score,allsegs] = seg_test_ltc3(trn,ww);
    testres.trn.score = score;
    testres.trn.allsegs = allsegs;

    fprintf('     Calculation LR test error.\n');
    [score,allsegs] = seg_test_ltc3(tst,ww);
    testres.tst.score = score;
    testres.tst.allsegs = allsegs;

    evalstr = ['save ' batchname '-results-lr.mat testres;'];
    eval(evalstr);

