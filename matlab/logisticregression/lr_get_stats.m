
function stats = lr_get_stats(ww,td);
% function stats = lr_get_stats(ww,td);
cc = [];
ff = [];
for i=1:td.num_pages;
    cc = [cc; td.pg{i}.cid];
    ff = [ff,td.pg{i}.features'];
end;

[ll,dll] = mefun(ww.weights,cc,ff,1e-3);

[llnosmoothing,dll2] = mefun(ww.weights,cc,ff,0);

llfromsmoothing = ll - llnosmoothing;

fprintf('LL = %4.4f, %4.4f% from smoothing.\n\n', ll, ...
        (100*llfromsmoothing/ll));
stats = 0;
