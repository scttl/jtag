

%Starting from an array of amounts of smoothing, a set of training data and a set of sample data:
Smoothing = [0.0001,0.0003,0.001,0.003,0.01,0.03,0.1,0.3];

%Load the training data
tdFile = '/h/40/klaven/klaven/Journals/TRAINING_DATA/jmlr.knn.data';
td = parse_training_data(tdFile);

%For each amount of smoothing
for ss = 1:length(Smoothing);

  %Find the lr weights
  lrw(ss) = create_lr_weights(td,Smoothing(ss),10000);

  %And save them
  dump_lr_weights(lrw(ss), strcat('/h/40/klaven/jtag/matlab/lrSmthTest/test',num2str(Smoothing(ss)),'.mat'));
end;

%Load the test data
testDir = '/h/40/klaven/klaven/Journals/TEST_DATA/jmlr';
testList = dir(strcat(testDir, '/*.jtag'));

Correct = zeros(size(Smoothing));
Total = zeros(size(Smoothing));

%For each test file
for tfNum = 1:length(testList);
  tf = testList(tfNum);
  jt = parse_jtag(strcat(testDir,'/',tf.name));

  %For each set of lr weights from different amounts of smoothing
  for wwNum = 1:length(lrw)
    ww = lrw(wwNum);

    %Evaluate the test file
    [cor,tot] = lr_test_file(jt,ww);

    %And store the results
    Correct(wwNum) = Correct(wwNum) + cor;
    Total(wwNum) = Total(wwNum) + tot;
  end;
end;

%Save the working environment for later use.
save kevTemp.mat;





