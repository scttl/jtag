function ff_out = memm_add_label_features(ff_in,label_text);
%
% function ff_out = memm_add_label_features(ff_in,label_text);
%
% Augments ff_in with binary features representing the feature
% class of label_text.  This function should be used to make sure
% the same numbering scheme is used for the feature labels
% throughout the program.
% 
% For MEMM's, label_text should be the text representation of the
% label of the previous region, or "start_of_page" for the first
% region.
% 

global class_names;

ff_out = [];

cnums = get_cid(label_text);

for ss = 1:size(ff_in,1);
    %cnum = 0;
    %for i = 1:length(class_names);
    %    if (strcmp(class_names{i},label_text(ss)));
    %        cnum = i;
    %    end;
    %end;
    cnum = cnums(ss);
    if ((cnum == 0) && (strcmp(char(label_text(ss)),'unknown') == 0));
        fprintf('Class name "%s" is not known.\n',char(label_text(ss)));
    else;
        %fprintf('Class name "%s" got cnum %i.\n',char(label_text(ss)),cnum);
        
    end;

    ff = ff_in(ss,:);
    for i = 0:length(class_names);
        ff = [ff,(cnum == i)];
    end;

    ff_out = [ff_out; ff];

end;
