function d_out = memm_predict(d,w);
%function d_out = memm_predict(d,w);
%
% Predict labels using MEMM, using the data d, and the weights w.
%

global class_names;

fprintf('Sorting test data elements.\n');
d = memm_sort(d);

d_out = d;

for i=1:length(d.pg);
    fprintf('Predicting page %i of %i.\n',i,length(d.pg));
    pred_path = predict_page(d.pg{i},w);
    d_out.pg{i}.pred_cid = zeros(length(d.pg{i}.cid),1);
    disp(pred_path.labels);
    disp(d.class_names(d.pg{i}.cid));
    for j=1:length(d.pg{i}.cid);
        for k = 1:length(d.class_names);
            if (strcmp(d.class_names(k),pred_path.labels(j+1)));
                d_out.pg{i}.pred_cid(d_out.pg{i}.sorted_index(j),1) = k;
            end;
        end;
    end;
end;
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function path = predict_page(pg,w);
%Predict the best label sequence for a given page.

global class_names;

prev_path(1).labels = {'start_of_page'};
prev_path(1).ll = log(1);

% for ss = step 1 to last
%     for nl = index of each possible next label
%         next_path(nl).ll = -inf;
%         for pp = index of each prev_path
%             Check the ll of [prev_path(pp).labels class_names(nl)].
%             If it is higher than the best ll for next_path(nl)
%                 Make it next_path(nl)

%lf = fopen('kevtemprecord.txt','w');

for ss = 1:size(pg.features,1);
    next_path = {};
    %fprintf(lf,'Starting iteration %i.\n',ss);
    for nl = 1:length(class_names)-1;
        %fprintf(lf,'    Testing class #%i, "%s".\n',nl,char(class_names(nl)));
        next_path(nl).ll = -inf;
        for pp = 1:length(prev_path);
            
            % loglikelihood = get this somehow.
            %fprintf(lf,'        Path #%i:{',pp);
            
            lpath = [prev_path(pp).labels, class_names(nl)];
            %for i=1:length(lpath);
                %fprintf(lf,'"%s" ',char(lpath(i)));
            %end;
            feats = pg.features(pg.sorted_index(1:(length(lpath)-1)));
            loglikelihood = memm_eval_sequence(feats, lpath, w, 0);
            %fprintf(lf,', ll=%f', loglikelihood);
            if (loglikelihood > next_path(nl).ll);
                next_path(nl).ll = loglikelihood;
                next_path(nl).labels = lpath;
                %fprintf(lf, ' <BEST>');
            end;
            %fprintf(lf,'\n');
        end;
    end;
    prev_path = next_path;
end;


% Finally, evaluate the completed paths.
% The winner is the one with the max LL when the end_of_page null
% feature is added on.
clear next_path;
next_path.ll = -inf;

%fprintf(lf,'Starting final iteration (#%i):\n', (size(pg.features,1)+1));
%fprintf(lf,'    Testing only possible label: "end_of_page":\n');
for pp = 1:length(prev_path);
    %fprintf(lf,'        Path #%i:{',pp);
    blankfeat = zeros(1,size(pg.features,2));
    feats = [pg.features(pg.sorted_index,:); blankfeat];
    lpath = [prev_path(pp).labels, {'end_of_page'}];
    %for i=1:length(lpath);
        %fprintf(lf,'"%s" ',char(lpath(i)));
    %end;
    loglikelihood = ...
        memm_eval_sequence(feats, lpath, w, 0);
    %fprintf(lf,', ll=%f', loglikelihood);
    if (loglikelihood > next_path.ll);
        next_path.ll = loglikelihood;
        next_path.labels = lpath;
        %fprintf(lf,' <BEST>');
    end;
    %fprintf(lf,'\n');
end;

fclose(lf);

path = next_path;



