function [score,allscores] = seg_test_xycut(data, HT, VT);

%function [score,allscores] = seg_test_xycut(data, HT, VT);
%
% Counts the total number of segmentation errors made by the
% xycut algorithm on data, using HT and VT as the horizontal
% and vertical thresholds respectively.  If HT and VT are not
% provided, the default values are used.
%
% -score is the sum of the log-likelihood estimates.
% -allscores is the sequence of log-likelihood estimates for
%  each page.
%


maxits = 10000;


clear allscores;
clear score;

if (length(VT) ~= length(HT));
    fprintf('VT and HT must have the same length.  They are used in pairs.\n');
    return;
end;

for tnum=1:length(VT);
    fprintf('Starting pair %i of %i: ht=%i, vt=%i\n',tnum, length(VT), ...
            HT(tnum), VT(tnum));
    score(tnum) = 0; 
    for j=1:min([maxits, data.num_pages]); 
        jt=jt_load(char(data.pg_names(j)),0);
        s = seg_eval_2(imread(char(jt.img_file)), ...
                       xycut(char(jt.img_file),HT(tnum),VT(tnum)), jt.rects);
        score(tnum) = score(tnum) + s; 
        fprintf('    Page %i of %i scored %f, for running total of %f\n', ...
                j, min([maxits, data.num_pages]), s, score(tnum)); 
        allscores(tnum,j) = s;
    end;
    save XYCut_Optimization_in_progress.mat HT VT score allscores;
end;
