function res = build_all_td(batchname);

    nipsTrainDirs = {'/p/learning/klaven/Journals/TAGGED/nips_2001/', ...
                     '/p/learning/klaven/Journals/TAGGED/nips_2002/'};
    nipsTestDirs = {'/p/learning/klaven/Journals/TEST_DATA/nips_2001/', ...
                    '/p/learning/klaven/Journals/TEST_DATA/nips_2002/'};

    jmlrTrainDirs = {'/p/learning/klaven/Journals/TAGGED/jmlr/'};
    jmlrTestDirs = {'/p/learning/klaven/Journals/TEST_DATA/jmlr/'};

    fprintf('For nips training data:\n');
    build_td(nipsTrainDirs,[batchname '-nips-train'],true);
    fprintf('For nips test data:\n');
    build_td(nipsTestDirs,[batchname '-nips-test'],false);

    fprintf('For jmlr training data:\n');
    build_td(jmlrTrainDirs,[batchname '-jmlr-train'],true);
    fprintf('For jmlr test data:\n');
    build_td(jmlrTestDirs,[batchname '-jmlr-test'],false);

    


%*********************************************
% Subfunction Declarations

function res = build_td(dirs,fname,dolr);


    trnfiles = {};
    for i=1:length(dirs);
        tmp1 = dir(strcat(dirs{i},'/*.jtag'));
        trnfiles = [trnfiles,strcat(dirs{i},{tmp1.name})];
    end;

    fprintf('     Found %i .jtag files in %i target dirs\n', ...
            length(trnfiles), length(dirs));

    tmp_td = {};
    fprintf('     Starting feature extraction\n');
    tmp_td = create_training_data(trnfiles);

    fprintf('     Done feature extraction.  Saving knn data.\n');
    dump_training_data(tmp_td, strcat(fname, '.knn.mat'));
    res = 1;

    if (nargin == 3) && dolr;
        tmp_td = parse_training_data(strcat(fname,'.knn.mat'));
        build_lr(tmp_td,fname);
        build_memm(tmp_td,fname);
        res = 1;
    end;

function res = build_lr(td, fname);

    fprintf('     Starting LR optimization');
    tmp_lrweights = create_lr_weights(td,1e-3,1e4);

    fprintf('     Done LR optimization.  Saving results.');
    dump_lr_weights(tmp_lrweights, strcat(fname, '.lr.mat'));

    weights_to_csv(tmp_lrweights, [fname '-lr-weights.csv']);
    
    res = 1;

function res = build_memm(td,fname);
    
    fprintf('    Starting MEMM optimization');
    tmp_memm_weights = memm_train(td,1e-3,1e4, strcat(fname,'.memm.mat'));
    fprintf('    Done MEMM optimization.  Results saved');

    weights_to_csv(tmp_memm_weights, [fname '-memm-weights.csv']);
    res = 1;
