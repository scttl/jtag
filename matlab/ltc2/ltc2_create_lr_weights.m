 function w = ltc2_create_lr_weights(samples, fn, sigma, maxevals, outfile)
% LTC2_CREATE_LR_WEIGHTS   Builds up a struct containing coefficient weights 
%                         for use in a logistical regression classifier.
%
%   W = CREATE_LR_WEIGHTS(SAMPLES, fn, [SIGMA, ITERATIONS, OUTFILE])  Attempts 
%   to build up and
%   optomize a set of coefficient weights for use in a logistic regression
%   classifier.  The DATA pased should either be a struct like that returned
%   from CREATE_TRAINING_DATA, or it can be a list of files like that passed
%   into CREATE_TRAINING_DATA.  This data will contain a list of features and
%   selections used to determine the weights.  The optional arguments that can
%   be specified include SIGMA, the inverse variance of the gaussian weight
%   prior (defaults to 1e-3), and ITERATIONS which specifies the maximum
%   number of evaluations performed during optomization (defaults to 1e8). 
%   The struct w returned has the following structure:
%
%     w.class_names -> cell array whose entries represent the string name of
%                      the class associated with that entry number.
%     w.weights -> MxN matrix of floating point numbers, where each M (row)
%                  represents a class (size(M) == size(w.class_names)), and
%                  each of the N columns corresponds to a weight value 
%                  (coefficient) for that feature.


if(nargin < 2) sigma = 1e-3; end
if(nargin < 3) maxevals = 1e4; end

cut_classes = {'no','yes'};
fnames = fn;

samps_hf = samples(find(and([samples.horizontal]==1,[samples.fullpage]==1)));
if (length(samps_hf) > 0);
    cids_hf = [samps_hf.valid] + 1;
    hf_fvals = reshape([samps_hf.feat_vals], ...
                       length(samps_hf(1).feat_vals),length(samps_hf));
    whf.anycuts = true;
    whf.class_names = cut_classes;
    whf.weights = [];
    whf.feature_names = fnames;
    whf.norm_add = - min(hf_fvals')';
    whf.norm_div = max(hf_fvals')' + whf.norm_add;
    whf.norm_div(find(whf.norm_div==0)) = 1;
    hf_fvals = hf_fvals + repmat(whf.norm_add,1,size(hf_fvals,2));
    hf_fvals = hf_fvals ./ repmat(whf.norm_div,1,size(hf_fvals,2));
    hf_C = length(whf.class_names);
    [hf_M,hf_N] = size(hf_fvals);
    [weightmatrix,llprogress,iterations] = ...
         minimize(sqrt(sigma)*randn((hf_M+1)*hf_C,1),'mefun', ...
                  maxevals,cids_hf,hf_fvals,sigma);
    whf.loglikelihoods = llprogress;
    whf.weights = reshape(weightmatrix(:),hf_M+1,hf_C);
else;
    whf.anycuts = false;
end;
w.whf = whf;


samps_hp = samples(find(and([samples.horizontal]==1,[samples.fullpage]==0)));
if (length(samps_hp) > 0);
    cids_hp = [samps_hp.valid] + 1;
    hp_fvals = reshape([samps_hp.feat_vals], ...
                       length(samps_hp(1).feat_vals),length(samps_hp));
    whp.class_names = cut_classes;
    whp.anycuts = true;
    whp.weights = [];
    whp.feature_names = fnames;
    whp.norm_add = - min(hp_fvals')';
    whp.norm_div = max(hp_fvals')' + whp.norm_add;
    whp.norm_div(find(whp.norm_div==0)) = 1;
    hp_fvals = hp_fvals + repmat(whp.norm_add,1,size(hp_fvals,2));
    hp_fvals = hp_fvals ./ repmat(whp.norm_div,1,size(hp_fvals,2));
    hp_C = length(whp.class_names);
    [hp_M,hp_N] = size(hp_fvals);
    [weightmatrix,llprogress,iterations] = ...
         minimize(sqrt(sigma)*randn((hp_M+1)*hp_C,1),'mefun', ...
                  maxevals,cids_hp,hp_fvals,sigma);
    whp.loglikelihoods = llprogress;
    whp.weights = reshape(weightmatrix(:),hp_M+1,hp_C);
else;
    whp.anycuts = false;
end;
w.whp = whp;


samps_vf = samples(find(and([samples.horizontal]==0,[samples.fullpage]==1)));
if (length(samps_vf) > 0);
    cids_vf = [samps_vf.valid] + 1;
    vf_fvals = reshape([samps_vf.feat_vals], ...
                       length(samps_vf(1).feat_vals),length(samps_vf));
    wvf.anycuts = true;
    wvf.class_names = cut_classes;
    wvf.weights = [];
    wvf.feature_names = fnames;
    wvf.norm_add = - min(vf_fvals')';
    wvf.norm_div = max(vf_fvals')' + wvf.norm_add;
    wvf.norm_div(find(wvf.norm_div==0)) = 1;
    vf_fvals = vf_fvals + repmat(wvf.norm_add,1,size(vf_fvals,2));
    vf_fvals = vf_fvals ./ repmat(wvf.norm_div,1,size(vf_fvals,2));
    vf_C = length(wvf.class_names);
    [vf_M,vf_N] = size(vf_fvals);
    [weightmatrix,llprogress,iterations] = ...
         minimize(sqrt(sigma)*randn((vf_M+1)*vf_C,1),'mefun', ...
                  maxevals,cids_vf,vf_fvals,sigma);
    wvf.loglikelihoods = llprogress;
    wvf.weights = reshape(weightmatrix(:),vf_M+1,vf_C);
else;
    wvf.anycuts = false;
end;
w.wvf = wvf;


samps_vp = samples(find(and([samples.horizontal]==0,[samples.fullpage]==0)));
if (length(samps_vp) > 0);
    cids_vp = [samps_vp.valid] + 1;
    vp_fvals = reshape([samps_vp.feat_vals], ...
                       length(samps_vp(1).feat_vals),length(samps_vp));
    % initialize output struct and fields
    wvp.anycuts = true;
    wvp.class_names = cut_classes;
    wvp.weights = [];
    wvp.feature_names = fnames;
    % Normalize features
    wvp.norm_add = - min(vp_fvals')';
    wvp.norm_div = max(vp_fvals')' + wvp.norm_add;
    wvp.norm_div(find(wvp.norm_div==0)) = 1;
    vp_fvals = vp_fvals + repmat(wvp.norm_add,1,size(vp_fvals,2));
    vp_fvals = vp_fvals ./ repmat(wvp.norm_div,1,size(vp_fvals,2));
    %A few more variables
    vp_C = length(wvp.class_names);
    [vp_M,vp_N] = size(vp_fvals);
    %Do the actual training.
    [weightmatrix,llprogress,iterations] = ...
         minimize(sqrt(sigma)*randn((vp_M+1)*vp_C,1),'mefun', ...
              maxevals,cids_vp,vp_fvals,sigma);
    wvp.loglikelihoods = llprogress;
    wvp.weights = reshape(weightmatrix(:),vp_M+1,vp_C);
else;
    wvp.anycuts = false;
end;
w.wvp = wvp;

if (nargin == 5);
    savedweightvar = w;
    evalstr = ['save ' outfile ' savedweightvar'];
    eval(evalstr);
end;

