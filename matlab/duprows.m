function b = duprows(m,n)
%DUPROWS Make interleaved copies of a matrix by repeating rows.
%B=DUPROWS(M,N)
%   M - Matrix of rows = [R1; R2; R3; ...].
%   N - Number of copies to make.
% Returns:
%   B= Matrix = [R1; R1; R1; R1; ... R2; R2; R2; R2; ....  ]
%   where each row in M appears N times.

[mr,mc] = size(m);


b = reshape(ones(n,1)*m(:)',mr*n,mc);


