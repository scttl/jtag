function res = lr_train(traindir, target);

temp = dir(strcat(traindir,'/*.tif'));
trnfiles = strcat(traindir,'/',{temp.name});
fprintf('Found %i .tif files in target dir\n', length(trnfiles));

fprintf('Starting feature extraction\n');
tmp_td = create_training_data(trnfiles);
fprintf('Done feature extraction.  Saving knn data.\n');
dump_training_data(tmp_td, strcat(target, '.knn.data'));

fprintf('Starting LR optimization');
tmp_lrweights = create_lr_weights(tmp_td,1e-3,1e4);
fprintf('Done LR optimization.  Saving results.');
dump_lr_weights(tmp_lrweights, strcat(target, '.lr.data'));

res = tmp_lrweights;
