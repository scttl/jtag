function [score,allscores] = seg_test_smear(data, HS, VS);

%function [score,allscores] = seg_test_smear(data, HS, VS);
%
% Counts the total number of segmentation errors made by the
% smear algorithm on data, using HS and VS as the horizontal
% and vertical smearing respectively.  If HS and VS are not
% provided, the default values are used.
%
% -score is the sum of the log-likelihood estimates.
% -allscores is the sequence of log-likelihood estimates for
%  each page.
%

clear allscores;
clear score;

if (length(VS) ~= length(HS));
    fprintf('VS and HS must have the same length.  They are used in pairs.\n');
    return;
end;

for tnum=1:length(VS);
    fprintf('Starting pair %i of %i: hs=%i, vs=%i\n',tnum, length(VS), ...
            HS(tnum), VS(tnum));
    score(tnum) = 0; 
    for j=1:data.num_pages; 
        jt=jt_load(char(data.pg_names(j)),0);
        pix = imread(char(jt.img_file));
        s = seg_eval_2(pix, smear(pix,HS(tnum),VS(tnum)), jt.rects);
        score(tnum) = score(tnum) + s; 
        fprintf('    Page %i of %i scored %f, for running total of %f\n', ...
                j, data.num_pages, s, score(tnum)); 
        allscores(tnum,j) = s;
    end;
    save Smear_Optimization_in_progress.mat HS VS score allscores;
end;
