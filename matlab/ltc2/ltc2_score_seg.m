function score = ltc2_score_samp(samp, ww);

if (samp.horizontal && samp.fullpage);
    score = score_using(samp,ww.whf);
elseif (samp.horizontal && ~samp.fullpage);
    score = score_using(samp,ww.whp);
elseif (~samp.horizontal && samp.fullpage);
    score = score_using(samp,ww.wvf);
elseif (~samp.horizontal && ~samp.fullpage);
    score = score_using(samp,ww.wvp);
else;
    fprintf('ERROR - impossible situation in ltc2_score_samp\n');
end;


function score = score_using(samp,ww);
%The "score" should be the log-likelihood of the "yes" label.

fnames = ww.feature_names;
fvals = reshape([samp.feat_vals],length(samps_hf(1).feat_vals),1);
cnames = ww.class_names;
fvals = fvals + ww.norm_add;
fvals = fvals ./ ww.norm_div;

C = length(cnames);
[M,N] = size(fvals);

logqq = ww.weights' * [fvals;ones(1,N)];
logpc = logqq - repmat(logsum(logqq,1),C,1);

if (~strcmp(cnames(2),'yes'));
    fprintf('ERROR - second class is not "yes".\n');
end;
score = logpc(2);

