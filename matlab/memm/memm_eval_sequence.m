function loglikelihood = memm_eval_sequence(feats,labels,weights,smoothing);
%
%function loglikelihood = memm_eval_sequence(feats,labels,weights,smoothing);
%
% Evaluates the label sequence labels on the feature sequence feats,
% using the weight matrix weights.
%
% Note that the labels vector should have 1 more element than the feats
% does.  This extra element should be the 'start_of_page' tag at the
% beginning.
%
% Returns the loglikelihood of the sequence.
%

global class_names;

if (nargin == 4);
    smth = smoothing;
else;
    smth = 0;
end;

ff = memm_add_label_features(feats,labels(1:(end-1)));

cid = [];
for i = 1:(length(labels)-1);
    cid(i) = 0;
    for j = 1:length(weights.class_names);
    %for j = 1:length(class_names);
        if (strcmp(labels(i+1),weights.class_names(j)));
        %if (strcmp(labels(i),class_names(j)));
            cid(i) = j;
        end;
    end;
end;


[ll,dll] = mefun(weights.weights,cid',ff',smth);

loglikelihood = -ll;

