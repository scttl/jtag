%Script to redo the memm training
function res = redo_memm;

global use;

use.dist = true;
use.snap = true;
use.pnum = true;
use.dens = true;
use.mark = false;
do_batch('./results/2004-07-29/2004-07-29');

use.dist = true;
use.snap = false;
use.pnum = true;
use.dens = true;
use.marks = false;
do_batch('./results/nosnap/nosnap');

use.dist = true;
use.snap = false;
use.pnum = true;
use.dense = true;
use.marks = true;
do_batch('./results/withmarks/marks');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function res = do_batch(bname);
    bn = [bname '-nips'];
    trn = parse_training_data([bn '-train.knn.mat']);
    tst = parse_training_data([bn '-test.knn.mat']);
    memm_w = build_memm(trn,[bn '-train']);
    test_set(bn);

    bn = [bname '-jmlr'];
    trn = parse_training_data([bn '-train.knn.mat']);
    tst = parse_training_data([bn '-test.knn.mat']);
    memm_w = build_memm(trn,[bn '-train']);
    test_set(bn);
    
    res = 1;



function res = build_memm(td,fname);
    
    fprintf('    Starting MEMM optimization');
    tmp_memm_weights = memm_train(td,1e-3,1e4, strcat(fname,'.memm.mat'));
    fprintf('    Done MEMM optimization.  Results saved');

    weights_to_csv(tmp_memm_weights, [fname '-memm-weights2.csv']);
    res = tmp_memm_weights;



function testres = test_set(batchname);

    fprintf('     Loading training data and weights.\n');
    trn = parse_training_data([batchname '-train.knn.mat']);
    tst = parse_training_data([batchname '-test.knn.mat']);
    memm_w = parse_lr_weights([batchname '-train.memm.mat']);
    fprintf('     Loading successful.\n');

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
                     [batchname '-results-memm-test2.csv']);
    lr_print_results(memm.trn.res,memm_w.class_names, ...
                     [batchname '-results-memm-train2.csv']);

