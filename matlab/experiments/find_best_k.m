function [ssumcor,ssumtot] = find_best_k(tstDir,tdFile,kVals);
%function [ssumcor,ssumtot] = find_best_k(tstDir,tdFile,kVals);

ssum_cor = zeros(1,length(kVals));
ssum_tot = zeros(1,length(kVals));

tstFiles = dir(strcat(tstDir, '/*.jtag'));



for kk = 1:length(kVals);
  fprintf('K = %i\n',kVals(kk));
  for ii = 1:size(tstFiles,1);
    % [cor,tot] = knn_test_file(strcat(tstDir,'/',tstFiles(ii).name),tdFile);

    filePath = strcat(tstDir,'/',tstFiles(ii).name);
    tdPath = tdFile;
    disp(filePath);
    ss=parse_training_data(tdPath);

    classes = ss.class_names;

    jt = parse_jtag(filePath);

    pixels = imread(jt.img_file);

    correct = 0;
    total = 0;

    for jj=1:size(jt.rects,1);
      total = total + 1;
      features = run_all_features(jt.rects(jj,:),pixels);
      predID = knn_fn(classes,features,tdPath,kVals(kk));
      %disp( strcat('Act=', jt.class_name(jt.class_id(jj)), ' Pred=', classes(predID)));
      if (strcmp(jt.class_name(jt.class_id(jj)), classes(predID)));
        correct = correct + 1;
      end;
    end;
    fprintf('For %s with k=%i, got %i / %i correct\n',filePath,kVals(kk),correct,total);
    %disp(strcat('total=',int2str(total),',correct=', int2str(correct)));

    ssum_cor(kk) = ssum_cor(kk) + correct;
    ssum_tot(kk) = ssum_tot(kk) + total;

    save kevTemp.mat ssum_cor ssum_tot;

  end;
end;

fprintf('Total correct: %i out of %i, or %f percent\n',ssum_cor,ssum_tot,(ssum_cor/ssum_tot));
%disp(ssum_cor/ssum_tot);


%jmlr test data dir: '/h/40/klaven/klaven/Journals/TEST_DATA/jmlr/'


%jmlr weights dir: '/h/40/klaven/klaven/Journals/TRAINING_DATA/jmlr.lr.data'



