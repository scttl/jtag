function [s1,s2,s3] = seg_test_all_ways(data,cutmethod,p1,p2);

%function [s1,s2,s3] = seg_test_all_ways(data,cutmethod,p1,p2);
%
% Applies the 3 segmentation error metrics to data, using
% the cutting method cutmethod, and passing parameters p1
% and p2 to cutmethod.
%

s1=0;
s2=0;
s3=0;

for j=1:data.num_pages; 
    fprintf('        Pg %i of %i.\n',j,data.num_pages);
    jt=jt_load(char(data.pg_names(j)),0);
    pix = imread(jt.img_file);
    if (strcmp(cutmethod,'xycuts') || strcmp(cutmethod,'xycut'));
        segs = xycut(pix,p1,p2);
    elseif (strcmp(cutmethod,'smear'));
        segs = smear(pix,p1,p2);
    elseif (strcmp(cutmethod,'voronoi') || strcmp(cutmethod,'voronoi1'));
        segs = voronoi1(pix,p1,p2);
    elseif (strcmp(cutmethod,'rgs') || strcmp(cutmethod,'RGS'));
        segs = rgs_page(jt,p1);
    elseif (strcmp(cutmethod,'LTC3') || strcmp(cutmethod,'ltc3'));
        segs = ltc3_cut_file(jt,p1,pix);
    end;
    
    [t1,t2,t3] = seg_eval_all_ways(pix,segs,jt.rects,jt.class_id);
    s1 = s1 + t1;
    s2 = s2 + t2;
    s3 = s3 + t3;
end;

