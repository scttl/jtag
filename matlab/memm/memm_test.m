function [correct, total, results, td] = memm_test(f_test, memm_weights);
% function [correct, total, results, td] = memm_test(f_test, memm_weights);

if ischar(memm_weights);
  ww=parse_lr_weights(memm_weights);
else
  ww=memm_weights;
end;

classes = ww.class_names;

if ischar(f_test);
    td = parse_training_data(f_test);
else
    td = f_test;
end;

td = memm_predict_2(td,ww);

fprintf('Prediction complete.  Calculating results.\n');

save kevtemp2004-07-15.mat td;

act_cnames = {};
act_cid = [];
pred_cnames = {};
pred_cid = [];
for i=1:length(td.pg);
    act_cid = [act_cid,td.pg{i}.cid];
    act_cnames = [act_cnames,td.class_names([td.pg{i}.cid])];
    pred_cid = [pred_cid,td.pg{i}.pred_cid'];
    pred_cnames = [pred_cnames,td.class_names([td.pg{i}.pred_cid])];
end;

results = zeros(length(classes),length(classes)+1);
for ii=1:length(act_cnames);
  jj = 1;
  while ~(strcmp(act_cnames(ii),classes(jj)))
    jj = jj + 1;
  end;
  kk = 1;
  while ~(strcmp(pred_cnames(ii),classes(kk)));
    kk = kk + 1;
  end;
  results(kk,jj) = results(kk,jj) + 1;

end;
total = sum(sum(results));
correct = trace(results);


