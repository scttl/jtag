function res = memm_build_all_td;

    res = 0;

    batchname = 'memm';
    sigma = 0.001;
    maxevals = 10000;

    fprintf('Loading nips training features.\n');
    nipstrn = parse_training_data('./features/nips-train-nomarks.knn.data');
    fprintf('Calculating nips weights.\n');
    nipsweights=memm_train(nipstrn,sigma,maxevals,'./memm/memm-nips.memm.mat');

    fprintf('Loading jmlr training features.\n');
    jmlrtrn = parse_training_data('./features/jmlr-train-nomarks.knn.data');
    fprintf('Calculating jmlr weights.\n');
    jmlrweights=memm_train(jmlrtrn,sigma,maxevals,'./memm/memm-jmlr.memm.mat');

    save ./memm/all-memm-weights.mat nipstrn nipsweights jmlrtrn jmlrweights;

    res = 1;
