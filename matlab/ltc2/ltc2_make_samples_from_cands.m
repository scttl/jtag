function [samps,fn] = ltc2_make_samples_from_cands(seg_cands,pix,jt,h,f,cs);
%
% function [samps,fn] = ltc2_make_samples_from_cands(seg_cands,pix,jt,h,f,cs);
%
% h = boolean: are the cuts horizontal?
% f = boolean: is this a run of full-page cuts?
% cs = current segment being split up.
%
samps = [];

%First, calculate features that appy to all samples on this page.
fakerect = [1 2 3 4];
if (nargin > 0);
    pnum_feats = pnum_features(fakerect, pix, char(jt.img_file));
else;
    pnum_feats = pnum_features();
end;

fn = {};
%List the feature names.
fn{1} = 's0_height';
fn{2} = 's1_height';
fn{3} = 'ws1_height';
fn{4} = 'ws2.height';
fn{5} = 's0_width';
fn{6} = 's1_width';
fn{7} = 'ws1_width';
fn{8} = 'ws2_width';
fn{9} = 's0_area';
fn{10} = 's1_area';
fn{11} = 'ws1_area';
fn{12} = 'ws2_area';
fn{13} = 'ws1_cuts_full_page';
fn{14} = 'ws2_cuts_full_page';
fn{15} = 's0.dens';
fn{16} = 's1.dens';
fn{17} = 'h_reduction';
fn{18} = 'v_reduction';
fn{19} = 's0.l';
fn{20} = 's0.r';
fn{21} = 's0.t';
fn{22} = 's0.b';
fn{23} = 's1.l';
fn{24} = 's1.r';
fn{25} = 's1.t';
fn{26} = 's1.b';
for j=1:size(pnum_feats,2);
    fn{26 + j} = pnum_feats(j).name;
end;

if (nargin == 0);
    samps = fn;
    return;
end;


if ~(length(seg_cands.segs_valid) == size(seg_cands.rects,1));
    fprintf('ERROR - seg_cands does not have same size rects and valids.\n');
end;

for i=1:length(seg_cands.segs_valid);
    cand = seg_cands.rects(i,:);
    cand = seg_snap(pix,cand,0);
    clear samp;

    samp.horizontal = h;
    samp.fullpage = f;
    samp.valid = seg_cands.segs_valid(i);

    if (isfield(seg_cands,'cut_before'));
        samp.cut_before = seg_cands.cut_before(i);
        samp.cut_after = seg_cands.cut_after(i);
    end;
    
    s0.l = cs(1);
    s0.r = cs(3);
    s0.t = cs(2);
    s0.b = cs(4);
    
    s1.l = cand(1);
    s1.r = cand(3);
    s1.t = cand(2);
    s1.b = cand(4);
    
    if ~h; %vertical cuts
        seg_left = [s0.l, s0.t, s1.l - 1, s0.b];
        seg_left = seg_snap(pix,seg_left,0);
        seg_right = [s1.r + 1, s0.t, s0.r, s0.b];
        seg_right = seg_snap(pix,seg_right,0);

        ws1.l = seg_left(3) + 1;
        ws1.r = s1.l - 1;
        ws1.t = s0.t;
        ws1.b = s0.b;

        ws2.l = s1.r + 1;
        ws2.r = s0.l - 1;
        ws2.t = s0.t;
        ws2.b = s0.b;
    else;
        seg_above = [s0.l, s0.t, s0.r, s1.t-1];
        seg_above = seg_snap(pix, seg_above, 0);
        seg_below = [s0.l, s1.b+1, s0.r, s0.b];
        seg_below = seg_snap(pix,seg_below,0);

        ws1.l = s0.l;
        ws1.r = s0.r;
        ws1.t = seg_above(4)+1;
        ws1.b = s1.t-1;

        ws2.l = s0.l;
        ws2.r = s0.r;
        ws2.t = s1.b+1;
        ws2.b = s0.b;
    end;
        
    samp.s0 = s0;
    samp.s1 = s1;
    samp.ws1 = ws1;
    samp.ws2 = ws2;

    %fn{1} = 's0_height';
    samp.feat_vals(1) = s0.b - s0.t + 1;
    %fn{2} = 's1_height';
    samp.feat_vals(2) = s1.b - s1.t + 1;
    %fn{3} = 'ws1_height';
    samp.feat_vals(3) = ws1.b - ws1.t + 1;
    %fn{4} = 'ws2.height';
    samp.feat_vals(4) = ws2.b - ws2.t + 1;
    
    %fn{5} = 's0_width';
    samp.feat_vals(5) = s0.r - s0.l + 1;
    %fn{6} = 's1_width';
    samp.feat_vals(6) = s1.r - s1.l + 1;
    %fn{7} = 'ws1_width';
    samp.feat_vals(7) = ws1.r - ws1.l + 1;
    %fn{8} = 'ws2_width';
    samp.feat_vals(8) = ws2.r - ws2.l + 1;

    %fn{9} = 's0_area';
    samp.feat_vals(9) = (s0.b - s0.t + 1) * (s0.r - s0.l + 1);
    %fn{10} = 's1_area';
    samp.feat_vals(10) = (s1.b - s1.t + 1) * (s1.r - s1.l + 1);
    %fn{11} = 'ws1_area';
    samp.feat_vals(11) = (ws1.b - ws1.t + 1) * (ws1.r - ws1.l + 1);
    %fn{12} = 'ws2_area';
    samp.feat_vals(12) = (ws2.b - ws2.t + 1) * (ws2.r - ws2.l + 1);

    %fn{13} = 'ws1_cuts_full_page';
    if (samp.horizontal);
        wsbox = pix(ws1.t:ws1.b, 1:size(pix,2));
        if (min(max(1-wsbox')) == 0);
            samp.feat_vals(13) = 1;
        else;
            samp.feat_vals(13) = 0;
        end;
    else;
        wsbox = pix(1:size(pix,1),ws1.l:ws1.r);
        if (min(max(1-wsbox)) == 0);
            samp.feat_vals(13) = 1;
        else;
            samp.feat_vals(13) = 0;
        end;
    end;

    %%fn?14} = 'ws2_cuts_full_page';
    if (samp.horizontal);
        wsbox = pix(ws2.t:ws2.b, 1:size(pix,2));
        if (min(max(1-wsbox')) == 0);
            samp.feat_vals(14) = 1;
        else;
            samp.feat_vals(14) = 0;
        end;
    else;
        wsbox = pix(1:size(pix,1),ws2.l:ws2.r);
        if (min(max(1-wsbox)) == 0);
            samp.feat_vals(14) = 1;
        else;
            samp.feat_vals(14) = 0;
        end;
    end;

    %fn?15} = 's0.dens';
    samp.feat_vals(15) = mean(mean(1-pix(s0.t:s0.b,s0.l:s0.r)));
    %fn?16} = 's1.dens';
    samp.feat_vals(16) = mean(mean(1-pix(s1.t:s1.b,s1.l:s1.r)));
    
    %fn?17} = 'h_reduction';
    samp.feat_vals(17) = (s0.r-s0.l+1) - min([(s1.r-s1.l+1),(ws1.r-ws1.l+1)]);

    %fn?18} = 'v_reduction';
    samp.feat_vals(18) = (s0.b-s0.t+1) - min([(s1.b-s1.t+1),(ws1.b-ws1.t+1)]);

    %fn?19} = 's0.l';
    samp.feat_vals(19) = s0.l;
    %fn?20} = 's0.r';
    samp.feat_vals(20) = s0.r;
    %fn?21} = 's0.t';
    samp.feat_vals(21) = s0.t;
    %fn?22} = 's0.b';
    samp.feat_vals(22) = s0.b;

    %fn?23} = 's1.l';
    samp.feat_vals(23) = s1.l;
    %fn?24} = 's1.r';
    samp.feat_vals(24) = s1.r;
    %fn?25} = 's1.t';
    samp.feat_vals(25) = s1.t;
    %fn?26} = 's1.b';
    samp.feat_vals(26) = s1.b;

    for j=1:size(pnum_feats,2);
        %fn?26 + j} = pnum_feats(j).name;
        samp.feat_vals(26 + j) = pnum_feats(j).val;
    end;
    samps = [samps;samp];
end;



