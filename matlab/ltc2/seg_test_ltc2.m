function [score,allsegs] = seg_test_ltc2(data, ww);

%function [score,allsegs] = seg_test_ltc2(data, ww);
%
% Counts the total number of segmentation errors made by the
% learn-to-cut algorithm on data, using ww as the weight matrix
%
% -score is the number of errors.
%


maxits = 10000;

tic;
clear score;
score = 0;
for j=1:min([maxits, data.num_pages]); 
    jt=jt_load(char(data.pg_names(j)),0);
    clear res;
    res.segs = ltc2_cut_file(jt,ww);
    res.jt_path = jt.jtag_file;
    allsegs(j) = res;
    s = seg_eval(imread(char(jt.img_file)), ...
                 ltc2_cut_file(jt,ww), jt.rects, jt.class_id);
    score = score + s; 
    fprintf('    Page %i of %i scored %f, for total %f, time=%i\n', ...
            j, min([maxits, data.num_pages]), s, score, ...
            floor(toc)); 
end;
save ltc2_Optimization_in_progress.mat score allsegs;

