
function [correct,total] = lr_test_file(filePath,tdPath);

%function [correct,total] = lr_test_file(filePath,tdPath);
%
%Tests a single .jtag file using K Nearest Neighbours, with the
%training data stored in the file at tdPath.
%
%fielPath: The path of a jtag file.
%tdPath: The path of a training data file.  Parse this file
%        using the parse_training_data function.
%correct: The number of correctly classified regions
%total: The number of regions

ss=parse_training_data(tdPath);

classes = ss.class_names;

jt = parse_jtag(filePath);

pixels = imread(jt.img_file);

correct = 0;
total = 0;

all_features = run_all_features(jt.rects,pixels);

for ii=1:size(jt.rects,1);
  total = total + 1;
  features = all_features(ii,:);
  predID = knn_fn(classes,features,tdPath);
  if (strcmp(jt.class_name(jt.class_id(ii)), classes(predID)));
    correct = correct + 1;
  end;
end;

