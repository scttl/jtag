function [segs,undersegs] = seg_test_overseg(data, HS, VS);

%function [segs,undersegs] = seg_test_overseg(data, HS, VS);
%
% Counts the total number of undersegmentations, as well as
% the total number of segments, made by the
% smear algorithm on data, using HS and VS as the horizontal
% and vertical smearing respectively.  If HS and VS are not
% provided, the default values are used.
%
% -undersegs is the number of undersegmentation errors
% -segs is the total number of segments
%

maxits = 100000;

segs = 0;
undersegs = 0;

if (length(VS) ~= length(HS));
    fprintf('VS and HS must have the same length.  They are used in pairs.\n');
    return;
end;

for tnum=1:length(VS);
    fprintf('Starting pair %i of %i: hs=%i, vs=%i\n',tnum, length(VS), ...
            HS(tnum), VS(tnum));
    segs(tnum) = 0; 
    undersegs(tnum) = 0;
    
    for j=1:min([maxits, data.num_pages]); 
        jt=jt_load(char(data.pg_names(j)),0);
        [us,s] = seg_eval_overseg(imread(char(jt.img_file)), ...
                               xycut(char(jt.img_file),HS(tnum),VS(tnum)), ...
                                     jt.rects);
        segs(tnum) = segs(tnum) + s;
        undersegs(tnum) = undersegs(tnum) + us;

        fprintf('    Page %i of %i, segs=%i, undersegs=%i\n.', ...
                j,min([maxits,data.num_pages]),segs(tnum),undersegs(tnum)); 
    end;
    save Overseg_Optimization_in_progress.mat HS VS segs undersegs;
end;
