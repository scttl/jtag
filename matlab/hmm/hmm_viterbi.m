function [qq,ll] = hmm_viterbi(Y,p0,T,O)
% [qq,ll] = hmm_viterbi(Y,p0,T,O)
%
% VITERBI DECODING for state estimation in Hidden Markov Models
%
% Y is a matrix of observations, one per column
%
% T(i,j) is the probability of going to j next if you are now in i
% p0(j)  is the probability of starting in state j
% C(q,j) is the q^th coordinate of the j^th state mean vector
% R(q,r) is the covariance between the q and r coordinate for observations
%        or a scalar if R is a multiple of the identity matrix	
%
% qq is the state path most likely to have generated Y given the model params
% ll is the joint likelihood of Y and qq given the model params
%    divided by the length of Y (to be consistent with fb)
%
% NOTE: this code is borrowed from Sam Roweis' implementation

% initial checking and nonsense
Y = Y';
C = O.Mu';
% since O.Var is a matrix of variances, want to deal with covariances
R = sqrt(O.Var);
%R = O.Var;
[pp,tau] = size(Y); [pp2,kk] = size(C); p0=p0(:);
assert(pp==pp2);  assert(length(p0)==kk);

% some constants
%if(all(size(R)==1))
%  intR=1; Rinv=1/R; z2=sqrt(Rinv^pp);
%else
%  intR=0; Rinv = inv(R); z2 = sqrt(det(Rinv));
%end
z1 = (2*pi)^(-pp/2); %zz=z1*z2;

% initialize space
delta=zeros(kk,tau);  psi=zeros(kk,tau); bb=zeros(kk,tau); qq=zeros(1,tau);

% compute bb
for ii=1:kk
  if C(1,ii) ~= NaN
      %rnz = R(ii,:) ~= 0; %only want to work with non-zero features
      %Rinv = inv(diag(R(ii,rnz)));
      Rinv = inv(diag(R(ii,:)));
      zz = z1 * sqrt(det(Rinv));
      %dd = Y(rnz,:)-C(rnz,ii)*ones(1,tau);
      dd = Y-C(:,ii)*ones(1,tau);
      bb(ii,:) = zz*exp(-.5*sum((Rinv*dd).*dd,1));
  else
      bb(ii,:) = NaN;
   end
end

% take logs of parameters for numerical ease, then use addition
p0 = log(p0+eps); T = log(T+eps); bb = log(bb+eps);

delta(:,1) = p0+bb(:,1); 
psi(:,1)=0;

for tt=2:tau
  [delta(:,tt),psi(:,tt)] = max((delta(:,tt-1)*ones(1,kk)+T)',[],2);
  delta(:,tt) = delta(:,tt)+bb(:,tt);
end

[ll,qq(tau)] = max(delta(:,tau));
%ll=ll/tau;

for tt=(tau-1):-1:1
  qq(tt)=psi(qq(tt+1),tt+1);
end

