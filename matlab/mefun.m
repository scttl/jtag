function [ll,dll] = mefun(lamvec,cc,ff,sigma)

% [ll,dll] = mefun(lamvec,cc,ff,sigma)
% Provides the Log Likelihood value (ll), as well as the gradient (dll)
% for use by the minimize function.
%
% lamvec: Weight vector at the start of this iteration
%
% ff: Features.  Each column contains the features for one data item.
%
% cc: Class ID's.  Each row contains the classID for one data item.
%
% sigma: the smoothing
%
% ff should NOT have the default feature, mefun will add that

[M,N] = size(ff);
C=length(lamvec(:))/(M+1);
lambda = reshape(lamvec(:),M+1,C);

lqq=lambda'*[ff;ones(1,N)];
%qq=exp(lqq);
%qqn=sum(qq,1);
lqqn = logsum(lqq,1);
logprobc = lqq-repmat(lqqn,C,1);
%probc = qq./repmat(qqn,C,1);
%probc=exp(logprobc);

ccidx = sub2ind([C,N],cc(:),(1:N)');

ccmat = zeros(C,N);
ccmat(ccidx)=1;


% negatives because we are minimizing!

ll  = - (sum(lqq(ccidx)) - sum(lqqn)) ...
      + .5*sigma*sum(lambda(:).^2);
dll = - sum(repmat([ff;ones(1,N)],C,1).* ...
       duprows(ccmat-exp(logprobc),M+1),2) + sigma*lambda(:);


% no gaussian prior
%ll  = - (sum(lqq(ccidx)) - sum(log(qqn)));
%dll = - sum(repmat([ff;ones(1,N)],C,1).*duprows(ccmat-probc,M+1),2);





% duprows(m,n)
%[mr,mc] = size(m);
%b = reshape(ones(n,1)*m(:)',mr*n,mc);
