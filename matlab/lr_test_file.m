
function [correct,total] = lr_test_file(filePath,wPath);

disp(filePath);

ww=parse_lr_weights(wPath);

classes = ww.class_names;

jt = parse_jtag(filePath);

pixels = imread(jt.img_file);

correct = 0;
total = 0;

for ii=1:size(jt.rects,1);
  total = total + 1; 
  features = run_all_features(jt.rects(ii,:),pixels); 
  predID = lr_fn(classes,features,wPath); 
  disp( strcat('Act=', jt.class_name(jt.class_id(ii)), ' Pred=', classes(predID))); 
  if (strcmp(jt.class_name(jt.class_id(ii)), classes(predID)));
    correct = correct + 1;
  end;
end;
disp(strcat('total=',int2str(total),',correct=', int2str(correct)));
