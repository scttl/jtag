function [correct,total,results] = knn_test(f_test, f_train);
% function [correct,total,results] = knn_test(f_test, f_train);

if (length(f_test.feat_names) ~= length(f_train.feat_names));
    error('TEST and TRAIN data must us the same features.');
    for i=1:length(f_test.feat_names);
        if (~strcmp(f_test.feat_names{i},f_train.feat_names{i}));
            error('TEST and TRAIN data must use the same features.');
        end;
    end;
end;



act_cnames = {};
act_cid = [];
feats = [];
for i=1:length(f_test.pg);
    act_cnames = [act_cnames,f_test.class_names([f_test.pg{i}.cid])];
    act_cid = [act_cid,f_test.pg{i}.cid'];
    feats = [feats; f_test.pg{i}.features];
end;

classes = f_train.class_names;
pred_cid = knn_fn(classes,feats,f_train);
pred_cn = classes(pred_cid);

results = zeros(length(classes),length(classes)+1);
for ii=1:length(act_cnames);
  jj = 1;
  while ~(strcmp(act_cnames(ii),classes(jj)))
    jj = jj + 1;
  end;
  results(pred_cid(ii),jj) = results(pred_cid(ii),jj) + 1;

end;
total = sum(sum(results));
correct = trace(results);

return;

correct = 0;
total = 0;
for i=1:length(cn);
    total = total + 1;
    if (strcmp(cn(i),f_train.class_names(cid(i))));
        correct = correct + 1;
    end;
end;

