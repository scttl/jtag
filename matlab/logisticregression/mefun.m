function [ll,dll] = mefun(w_vec,cc,ff,smoothing)

% [ll,dll] = mefun(w_vec,cc,ff,smoothing)
% Provides the Log Likelihood value (ll), as well as the gradient (dll)
% for use by the minimize function.
%
% w_vec: Weight vector at the start of this iteration
%
% ff: Features.  Each column contains the features for one data item.
%
% cc: Class ID's.  Each row contains the classID for one data item.
%
% smoothing: the smoothing
%
% ff should NOT have the default feature, mefun will add that

[M,N] = size(ff);
C=length(w_vec(:))/(M+1);
ww = reshape(w_vec(:),M+1,C);

lqq=ww'*[ff;ones(1,N)];
lqqn = logsum(lqq,1);
logprobc = lqq-repmat(lqqn,C,1);
ccidx = zeros(C,N);
for i=1:N;
    if (cc(i)==0);
        fprintf('Found cc(%i) was 0.\n',i);
    end;
    ccidx(cc(i),i) = 1;
end;
ccidx = sub2ind([C,N],cc(:),(1:N)');

ccmat = zeros(C,N);
ccmat(ccidx)=1;


% negatives because we are minimizing!

ll  = - (sum(lqq(ccidx)) - sum(lqqn)) ...
      + .5*smoothing*sum(ww(:).^2);
dll = - sum(repmat([ff;ones(1,N)],C,1).* ...
       duprows(ccmat-exp(logprobc),M+1),2) + smoothing*ww(:);


% no smoothing
%ll  = - (sum(lqq(ccidx)) - sum(log(qqn)));
%dll = - sum(repmat([ff;ones(1,N)],C,1).*duprows(ccmat-probc,M+1),2);

