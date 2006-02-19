function params = rgs_get_params(td,savepath);

extra_stddev_factor = 0.01;
extra_stddev = 1/sqrt(2*pi);
extra_stddev = 0.07;
prior_smoothing = 1;
beta_smoothing = 1;

global class_names;
[feats,cids] = get_all_features(td);

means = zeros(length(class_names),size(feats,2));
sigmas = zeros(length(class_names),size(feats,2));

for i=1:length(class_names);
    ff = feats(find(cids==i),:);
    if (length(ff) > 0);
        pix_tot = ff(:,11) * (2156*1728);  %Feature 11 is area
        pix_on = pix_tot .* ff(:,23);      %Feature 23 is rect_dens
        alphas(i) = (sum(pix_on)+1) ./ (sum(pix_tot)+2);
        means(i,:) = mean(ff);
        sigmas(i,:) = std(ff) + ...
                      max(repmat(extra_stddev,1,size(ff,2)), ...
                          (extra_stddev_factor * means(i,:)));
        betas(i,:) = (sum(ff==1) + beta_smoothing) ./ ...
                     (sum(ff==1) + sum(ff==0) + (2*beta_smoothing));
        anysamples(i) = true;
    else;
        alphas(i) = 0;
        means(i,:) = -inf;
        sigmas(i,:) = extra_stddev;
        betas(i,:) = 0.5;
        anysamples(i) = false;
    end;
    priors(i) = (size(ff,1) + prior_smoothing) / ...
                (size(feats,1) + (length(class_names) * prior_smoothing));
end;

params.alphas = alphas;
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
params.bg_alpha = 0.001;

if (nargin >=2);
    evalstr = ['save ' savepath ' params'];
    eval(evalstr);
end;
