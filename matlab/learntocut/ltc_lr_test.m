function [correct, total, results] = ltc_lr_test(f_test, lr_weights);
% function [correct, total, results] = ltc_lr_test(f_test, lr_weights);

if ischar(lr_weights);
  ww=parse_lr_weights(lr_weights);
else
  ww=lr_weights;
end;

classes = [ww.wv.class_names,ww.wh.class_names];

if ischar(f_test);
    evalstr = ['load ' f_test];
    eval(evalstr);
    td = samples;
else
    td = f_test;
end;

sh = samples(find([samples.horizontal]));
sv = samples(find(1 - [samples.horizontal]));

h_allfeats = reshape([sh.feat_vals], ...
                     length(sh(1).feat_vals),length(sh));
v_allfeats = reshape([sv.feat_vals], ...
                     length(sv(1).feat_vals),length(sv));

h_act_cid = 5 + ([sh.fullpage] * 2) + ([sh.valid_cut]);
v_act_cid = 1 + ([sv.fullpage] * 2) + ([sv.valid_cut]);

cut_classes = {'v_part_no','v_part_yes','v_full_no','v_full_yes', ...
               'h_part_no','h_part_yes','h_full_no','h_full_yes'};

h_act_cnames = cut_classes(h_act_cid);
v_act_cnames = cut_classes(v_act_cid);

h_pred_cid = 4 + lr_fn(cut_classes(5:8),h_allfeats','null',ww.wh);
v_pred_cid = lr_fn(cut_classes(1:4),v_allfeats','null',ww.wv);

h_pred_cnames = [cut_classes(h_pred_cid)];
v_pred_cnames = [cut_classes(v_pred_cid)];

act_cid = [h_act_cid, v_act_cid];
pred_cid = [h_pred_cid, v_pred_cid];


results = zeros(length(cut_classes),length(cut_classes));
for ii=1:length(act_cid);
    results(pred_cid(ii),act_cid(ii)) = results(pred_cid(ii),act_cid(ii))+1;
end;

total = sum(sum(results));
correct = trace(results);

