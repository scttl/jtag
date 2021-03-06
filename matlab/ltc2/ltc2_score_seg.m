function [score_y,score_n] = ltc2_score_seg(samp, ww);

if (samp.horizontal && samp.fullpage);
    [score_y,score_n] = score_using(samp,ww.whf);
elseif (samp.horizontal && ~samp.fullpage);
    [score_y,score_n] = score_using(samp,ww.whp);
elseif (~samp.horizontal && samp.fullpage);
    [score_y,score_n] = score_using(samp,ww.wvf);
elseif (~samp.horizontal && ~samp.fullpage);
    [score_y,score_n] = score_using(samp,ww.wvp);
else;
    fprintf('ERROR - impossible situation in ltc2_score_samp\n');
end;


function [score_y,score_n] = score_using(samp,ww);
%The "score" should be the log-likelihood of the "yes" label.

if (~ww.anycuts);
    score_y = -inf;
    score_n = 0;
    return;
end;

fnames = ww.feature_names;
fvals = reshape([samp.feat_vals],length(samp.feat_vals),1);
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
score_y = logpc(2);
score_n = logpc(1);

