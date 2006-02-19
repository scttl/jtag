function [correct, total, results] = gaussnb_test(f_test, params);

if ischar(params);
  load params;
else
  Py = params.Py;
  Mu = params.Mu;
  Var = params.Var;
end;

global class_names;

classes = class_names;

if ischar(f_test);
    td = parse_training_data(f_test);
else
    td = f_test;
end;

%@@normalize the data
norms = find_norms(td);
td = normalize_td(td,norms);

allfeats = [];
act_cnames = {};
act_cid = [];
for i=1:length(td.pg);
    allfeats = [allfeats; td.pg{i}.features];
    act_cid = [act_cid,reshape(td.pg{i}.cid,1,length(td.pg{i}.cid))];
    act_cnames = [act_cnames,td.class_names([td.pg{i}.cid])];
end;

pred_cid = gaussnb_fn(allfeats,Py, Mu, Var);
pred_cnames = [classes(pred_cid)];

results = zeros(length(classes),length(classes)+1);
for ii=1:length(act_cnames);
  jj = 1;
  while ~(strcmp(act_cnames(ii),classes(jj)))
    jj = jj + 1;
  end;
  results(pred_cid(ii),jj) = results(pred_cid(ii),jj) + 1;
end

total = sum(sum(results));
correct = trace(results);
