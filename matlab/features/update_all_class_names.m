function res = update_all_class_names;
%
% function res = update_all_class_names;
%
% Updates the class names for all of the training and test data.
%

    update_td_class_names('./features/nips-train-nomarks.knn.data');
    update_td_class_names('./features/nips-test-nomarks.knn.data');
    update_td_class_names('./features/jmlr-train-nomarks.knn.data');
    update_td_class_names('./features/jmlr-test-nomarks.knn.data');

