function [score,allscores] = seg_test_voronoi(data, Td1, Td2);

%function [score,allscores] = seg_test_voronoi(data, Td1, Td2);
%


maxits = 10000;


clear allscores;
clear score;

if (length(Td1) ~= length(Td2));
    fprintf('Td1 and Td2 must have same length.  They are used in pairs.\n');
    return;
end;

for tnum=1:length(Td1);
    fprintf('Starting pair %i of %i: Td1=%i, Td2=%i\n',tnum, length(Td1), ...
            Td1(tnum), Td2(tnum));
    score(tnum) = 0; 
    for j=1:min([maxits, data.num_pages]); 
        jt=jt_load(char(data.pg_names(j)),0);
        pix = imread(char(jt.img_file));
        if (nargin < 3);
            s = seg_eval_2(pix,voronoi1(pix),jt.rects); 
        else;
            s = seg_eval_2(pix, voronoi1(pix,Td1(tnum),Td2(tnum)), ...
                           jt.rects);
        end;
        score(tnum) = score(tnum) + s; 
        fprintf('    Page %i of %i scored %f, for running total of %f\n', ...
                j, min([maxits, data.num_pages]), s, score(tnum)); 
        allscores(tnum,j) = s;
    end;
    save Voronoi_Optimization_in_progress.mat Td1 Td2 score allscores;
end;
