
function [correct,total,results] = lr_test_file(jt_file,lr_weights);

%function [correct,total,results] = lr_test_file(jt_file,lr_weights);
%function [correct,total] = lr_test_file(jt_file,lr_weights);
%
%Tests a single .jtag file using logistic regression, with the weights
%specified.
%
%jt_file: a parsed jtag file, or the path of a jtag file.
%lr_weights: a parsed lr_weights file, or the path of a
%            lr_weights file.
%correct: The number of correctly classified regions
%total: The number of regions
%results: A matrix of results.  Results(pred,cor) is the
%         number of times ww.classnames(pred) was the
%         predicted value, and ww.classnames(cor) was
%         the correct value.

if ischar(lr_weights);
  ww=parse_lr_weights(lr_weights);
else
  ww=lr_weights;
end;

classes = ww.class_names;
results = zeros(length(classes),length(classes)+1);

if ischar(jt_file);
  jt = parse_jtag(jt_file);
else
  jt = jt_file;
end;

pixels = imread(jt.img_file);

correct = 0;
total = 0;

for ii=1:size(jt.rects,1);
  total = total + 1;
  features = run_all_features(jt.rects(ii,:),pixels);
  predID = lr_fn(classes,features,ww);
  actClass = jt.class_name(jt.class_id(ii));
  jj = 1;
  while ~(strcmp(actClass,classes(jj)))
    jj = jj + 1;
  end;
  results(predID,jj) = results(predID,jj) + 1;

  if (strcmp(jt.class_name(jt.class_id(ii)), classes(predID)));
    correct = correct + 1;
  end;
end;

