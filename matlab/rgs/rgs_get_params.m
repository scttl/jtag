function params = rgs_get_params(td);

extra_stddev_factor = 0.01;
%extra_stddev = 1/(sqrt(2*pi)); %0.3989
extra_stddev = 0.05;
extra_stddev = 0.07;
prior_smoothing = 1;
beta_smoothing = 1;

[feats,cids] = get_all_feats(td);

global class_names;

means = zeros(length(class_names),size(feats,2));
sigmas = zeros(length(class_names),size(feats,2));

for i=1:length(class_names);
    ff = feats(find(cids==i),:);
    if (length(ff) > 0);
        means(i,:) = mean(ff);
        sigmas(i,:) = std(ff) + ...
                      max(repmat(extra_stddev,1,size(ff,2)), ...
                          (extra_stddev_factor * means(i,:)));
        betas(i,:) = (sum(ff==1) + beta_smoothing) ./ ...
                     (sum(ff==1) + sum(ff==0) + (2*beta_smoothing));
        anysamples(i) = true;
    else;
        means(i,:) = -inf;
        sigmas(i,:) = extra_stddev;
        betas(i,:) = 0.5;
        anysamples(i) = false;
    end;
    priors(i) = (size(ff,1) + prior_smoothing) / ...
                (size(feats,1) + (length(class_names) * prior_smoothing));
end;

params.means = means;
params.sigmas = sigmas;
params.betas = betas;
params.anysamples = anysamples;
params.priors = priors;
params.feat_names = td.feat_names;
params.class_names = class_names;
params.is_bool = td.is_bool;
params.is_gaus = td.is_gaus;
params.feat_normalized = td.feat_normalized;


