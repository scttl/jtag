function res = build_all_td(batchname);

    nipsTrainDirs = {'/p/learning/klaven/Journals/TAGGED/nips_2001/', ...
                     '/p/learning//klaven/Journals/TAGGED/nips_2002/'};
    nipsTestDirs = {'/p/learning/klaven/Journals/TEST_DATA/nips_2001/', ...
                    '/p/learning/klaven/Journals/TEST_DATA/nips_2002/'};

    jmlrTrainDirs = {'/p/learning/klaven/Journals/TAGGED/jmlr/'};
    jmlrTestDirs = {'/p/learning/klaven/Journals/TEST_DATA/jmlr/'};

    fprintf('For nips training data:\n');
    build_td(nipsTrainDirs,['nips-train-',batchname],true);
    fprintf('For nips test data:\n');
    build_td(nipsTestDirs,['nips-test-',batchname],false);

    fprintf('For jmlr training data:\n');
    build_td(jmlrTrainDirs,['jmlr-train-',batchname],true);
    fprintf('For jmlr test data:\n');
    build_td(jmlrTestDirs,['jmlr-test-',batchname],false);


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
    dump_training_data(tmp_td, strcat(fname, '.knn.data'));

    if (nargin == 3) && dolr;
        build_lr(tmp_td,fname);
    end;

function res = build_lr(td, fname);

    fprintf('     Starting LR optimization');
    tmp_lrweights = create_lr_weights(td,1e-3,1e4);

    fprintf('     Done LR optimization.  Saving results.');
    dump_lr_weights(tmp_lrweights, strcat(fname, '.lr.mat'));

