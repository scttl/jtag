 function w = ltc_create_lr_weights(samples, sigma, maxevals, outfile)
% LTC_CREATE_LR_WEIGHTS   Builds up a struct containing coefficient weights 
%                         for use in a logistical regression classifier.
%
%   W = CREATE_LR_WEIGHTS(SAMPLES, [SIGMA, ITERATIONS, OUTFILE])  Attempts to 
%   build up and
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

%Class name scheme (add 1 to each):
%  Binary  Decimal  Meaning
%   000       0     v_no
%   001       1     v_yes
%   010       2     UNUSED
%   011       3     UNUSED
%   100       4     h_part_no
%   101       5     h_part_yes
%   110       6     h_full_no
%   111       7     h_full_yes
cut_classes = {'v_no','v_yes','UNUSED','UNUSED', ...
               'h_part_no','h_part_yes','h_full_no','h_full_yes'};

sh = samples(find([samples.horizontal]));
sv = samples(find(1 - [samples.horizontal]));

h_cids = (([sh.fullpage] * 2) + ([sh.valid_cut]));
h_cids = 1 + h_cids;
v_cids = [sv.valid_cut];
v_cids = 1 + v_cids;

fnames = samples(1).feat_names;

h_fvals = reshape([sh.feat_vals], length(sh(1).feat_vals),length(sh));
v_fvals = reshape([sv.feat_vals], length(sv(1).feat_vals),length(sv));
                
% initialize output struct and fields
wv.class_names = cut_classes(1:2);
wv.weights = [];
wv.feature_names = fnames;
wh.class_names = cut_classes(5:8);
wh.weights = [];
wh.feature_names = fnames;

wh.norm_add = - min(h_fvals')';
wh.norm_div = max(h_fvals')' + wh.norm_add;

wv.norm_add = - min(v_fvals')';
wv.norm_div = max(v_fvals')' + wv.norm_add;


h_fvals = h_fvals + repmat(wh.norm_add,1,size(h_fvals,2));
h_fvals = h_fvals ./ repmat(wh.norm_div,1,size(h_fvals,2));

v_fvals = v_fvals + repmat(wv.norm_add,1,size(v_fvals,2));
v_fvals = v_fvals ./ repmat(wv.norm_div,1,size(v_fvals,2));


h_C = length(wh.class_names);
[h_M,h_N] = size(h_fvals);

v_C = length(wv.class_names);
[v_M,v_N] = size(v_fvals);


%fprintf('h_C=%i, h_M=%i, h_N=%i\n',h_C,h_M,h_N);
%fprintf('v_C=%i, v_M=%i, v_N=%i\n',v_C,v_M,v_N);


[weightmatrix,llprogress,iterations] = ...
     minimize(sqrt(sigma)*randn((h_M+1)*h_C,1),'mefun', ...
              maxevals,h_cids,h_fvals,sigma);
wh.loglikelihoods = llprogress;
wh.weights = reshape(weightmatrix(:),h_M+1,h_C);

[weightmatrix,llprogress,iterations] = ...
     minimize(sqrt(sigma)*randn((v_M+1)*v_C,1),'mefun', ...
              maxevals,v_cids,v_fvals,sigma);
wv.loglikelihoods = llprogress;
wv.weights = reshape(weightmatrix(:),v_M+1,v_C);

w.wh = wh;
w.wv = wv;

if (nargin == 4);
    savedweightvar = w;
    evalstr = ['save ' outfile ' savedweightvar'];
    eval(evalstr);
end;

