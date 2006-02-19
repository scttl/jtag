function [correct, total, results] = hmm_test(f_test, params);

if ischar(params);
  load params;
else
  T = params.T;
  O = params.O;
end;

global class_names;

classes = class_names;
% the distribution for the first item in any sequence is always the
% start_of_page tag, so we define this
sop = get_cid('start_of_page');
init_probs = zeros(length(classes),1);
init_probs(sop) = 1.0;

if ischar(f_test);
    td = parse_training_data(f_test);
else
    td = f_test;
end;

%start by normalizing the data (if it isn't already)
norms = find_norms(td);
td = normalize_td(td, norms);

%ensure the data gets sorted (if it isn't already)
if (~ isfield(td, 'isSorted') || ~ td.isSorted);
   td = mm_sort(td);
end

%After the elements are sorted, add the binarized sequence label features
td = memm_add_td_label_features(td);

allfeats = [];
act_cnames = {};
act_cid = [];
pred_cid = [];
for i=1:length(td.pg);
    allfeats = [allfeats; td.pg{i}.features];
    act_cid = [act_cid,reshape(td.pg{i}.cid,1,length(td.pg{i}.cid))];
    act_cnames = [act_cnames,td.class_names([td.pg{i}.cid])];
    [preds, DUMMY] = hmm_viterbi(td.pg{i}.features, init_probs, T, O);
    pred_cid = [pred_cid; preds'];
end

pred_cnames = [classes(pred_cid)];

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
