function lls = rgs_region_ll(feats,params);
%
%function lls = rgs_region_ll(feats,params);
%
%Given the feature vector and parameters, returns the region
%log likelihoods for each class name.
%

per_region_penalty = 5;  %Both the gaussian method and the ink method tend
                         %to encourage oversegmentation.  This per-region
                         %penalty factor compensates for this.
%For smoothing = 0.07, pix_ll_const = 0
per_region_penalty = 5;  %Too small
per_region_penalty = 50; %Too big
per_region_penalty = 30; %Too big
per_region_penalty = 15; %Too big
per_region_penalty = 10; %Right ballpark.  Perhaps a bit too big.
per_region_penalty = 7;  %Too small
per_region_penalty = 8.5; %Right ballpark.  Perhaps a bit too small.
per_region_penalty = 9;   %Right ballpark.  Perhaps a bit too small.
per_region_penalty = 9.5; %Right ballpark.  Perhaps a bit too big.
%Ballpark is cleary in the 8-10 range.

%For smoothing = 0.07, pix_ll_const = 1;
per_region_penalty = 9; %Too small
per_region_penalty = 1000; %Too small
per_region_penalty = 100000; %Too large, but getting close.
per_region_penalty =  50000; %Too large, but getting close.
per_region_penalty =  10000; %Too large
per_region_penalty =   5000; %Too large
per_region_penalty =   2000; %Just a bit too large
per_region_penalty =   1700; %Just a bit too large
per_region_penalty =   1500; %Mighty close - maybe a bit large.
per_region_penalty =   1200; %Too small
per_region_penalty =   1400; %Too small
%Ballpark is clearly the 1400-1600 range.

%For smoothing = 0.07, pix_ll_const = 167
per_region_penalty = 18;  %Close.  Maybe a tad too small
per_region_penalty = 20;  %Mighty close.  Maybe a tad too small
per_region_penalty = 22;  %Mighty close.  Maybe a tad too big
per_region_penalty = 21;  %Mighty close.  Maybe a tad too small
%Ballpark is clearly the 20-23 range

per_region_penalty = 30;  %Was too small for my second test page.
per_region_penalty = 40;  %This worked for my second page chosen.
per_region_penalty = 25;  %This seems to work reasonably most of the time.

%Best value is probably in the 20-40 range.

%For smoothing = 1/sqrt(2*pi)
pix_ll_const = 0.0001; %too small
pix_ll_const = 0.001;  %too small
pix_ll_const = 0.01;   %Right ballpark for smoothing=(1/sqrt(2pi)).

%For smoothing = 0.07
pix_ll_const = 0.0001; %too small?
pix_ll_const = 0.001;
pix_ll_const = 1/167;

global class_names;

%pix_on = zeros(size(rects,1));
%pix_tot = zeros(size(rects,1));
%for i=1:size(rects,1);
%    r=rects(i,:);
%    pix_on(i) = sum(sum(1-pix(r(2):r(4),r(1):r(3))));
%    pix_tot(i) = (r(4)-r(2)+1)*(r(3)-r(1)+1);
%end;
%pix_off = pix_tot - pix_on;
pix_tot = feats(:,11) * (2156*1728);             %area
pix_on = pix_tot .* feats(:,23);                 %rect_dens
pix_off = pix_tot - pix_on;

warning off MATLAB:log:logOfZero;
for j=1:size(feats,1);
    ff = feats(j,:);
    for i=1:length(class_names);
        if (params.anysamples(i));
            means = params.means(i,:);
            sigma = params.sigmas(i,:);
            betas = params.betas(i,:);
            alpha = params.alphas(i);
            pix_ll = (pix_on(j) * log(alpha)) + ...
                     (pix_off(j) * log(1-alpha));
            
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
                       sum(gaus_lls) + ...
                       (pix_ll_const * pix_ll) - ...
                       per_region_penalty;
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

