function lls = rgs_region_ll(feats,params);
%
%function lls = rgs_region_ll(feats,params);
%
%Given the feature vector and parameters, returns the region
%log likelihoods for each class name.
%

global class_names;

warning off MATLAB:log:logOfZero;
for j=1:size(feats,1);
    ff = feats(j,:);
    for i=1:length(class_names);
        if (params.anysamples(i));
            means = params.means(i,:);
            sigma = params.sigmas(i,:);
            betas = params.betas(i,:);
            
            g = find(params.is_gaus);
            %gaus_lls = log(1/(sqrt(2 * pi) * sigma(g))
            gaus_lls = log(((sqrt(2 * pi) .* sigma(g)).^(-1)) .* ...
                            exp(-((ff(g) - means(g)).^2 ./ (2*(sigma(g)).^2))));
            %gaus_lls = log((sqrt(2 * pi) .* sigma(g)).^(-1)) - ...
            %                ((ff(g) - means(g)).^2 ./ (2*(sigma(g)).^2));
            %if (max(max(gaus_lls)) > 0);
            %    fprintf('Weird: guas_lls > 0.\n');
            %    disp(gaus_lls);
            %end;

            b = find(params.is_bool);
            bool_lls = log((ff(b) .* betas(b)) + ((1-ff(b)) .* (1-betas(b))));
            %if (max(max(bool_lls)) > 0);
            %    fprintf('Weird: bool_lls > 1.\n');
            %    disp(bool_lls);
            %end;

            lls(j,i) = log(params.priors(i)) + ...
                       sum(bool_lls) + ...
                       sum(gaus_lls(1:18));
        else;
            lls(j,i) = -inf;
        end;
    end;
end;
warning on MATLAB:log:logOfZero;

tmp = reshape(lls,1,prod(size(lls)));
tmp(find(isnan(tmp))) = -inf;
lls = reshape(tmp,size(lls));

%lls(find(isnan(lls))) = -inf;

