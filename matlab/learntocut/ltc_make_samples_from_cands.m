function samps = ltc_make_samples_from_cands(candidates, pix, jt);
samps = [];

%First, calculate features that appy to all samples on this page.
fakerect = [1 2 3 4];
pnum_feats = pnum_features(fakerect, pix, char(jt.img_file));

for i=1:length(candidates);
    cand = candidates(i);
    clear samp;

    samp.horizontal = strcmp(cand.direction, 'horizontal');
    if (isfield(cand,'fullpage'));
        samp.fullpage = cand.fullpage;
    end;
    if (isfield(cand,'valid_cut'));
        samp.valid_cut = cand.valid_cut;
    end;

    s0.l = cand.seg_left;
    s0.r = cand.seg_right;
    s0.t = cand.seg_top;
    s0.b = cand.seg_bot;
    
    if strcmp(cand.direction, 'vertical');
        s1box = [s0.l, s0.t, cand.x - 1, s0.b];
        s1box = seg_snap(pix,s1box,0);
        s1.l = s1box(1);
        s1.r = s1box(3);
        s1.t = s1box(2);
        s1.b = s1box(4);

        s2box = [cand.x + 1, s0.t, s0.r, s0.b];
        s2box = seg_snap(pix,s2box,0);
        s2.l = s2box(1);
        s2.r = s2box(3);
        s2.t = s2box(2);
        s2.b = s2box(4);

        ws.l = s1.r + 1;
        ws.r = s2.l - 1;
        ws.t = s0.t;
        ws.b = s0.b;
    else;
        s1box = [s0.l, s0.t, s0.r, cand.y - 1];
        s1box = seg_snap(pix,s1box,0);
        s1.l = s1box(1);
        s1.r = s1box(3);
        s1.t = s1box(2);
        s1.b = s1box(4);

        s2box = [s0.l, cand.y + 1, s0.r, s0.b];
        s2box = seg_snap(pix,s2box,0);
        s2.l = s2box(1);
        s2.r = s2box(3);
        s2.t = s2box(2);
        s2.b = s2box(4);

        ws.l = s0.l;
        ws.r = s0.r;
        ws.t = s1.b + 1;
        ws.b = s2.t - 1;
    end;
    
    samp.s0 = s0;
    samp.s1 = s1;
    samp.s2 = s2;
    samp.ws = ws;

    samp.feat_names{1} = 's0_height';
    samp.feat_vals(1) = s0.b - s0.t + 1;
    samp.feat_names{2} = 's1_height';
    samp.feat_vals(2) = s1.b - s1.t + 1;
    samp.feat_names{3} = 's2_height';
    samp.feat_vals(3) = s2.b - s2.t + 1;
    samp.feat_names{4} = 'ws.height';
    samp.feat_vals(4) = ws.b - ws.t + 1;
    samp.feat_names{5} = 's0_width';
    samp.feat_vals(5) = s0.r - s0.l + 1;
    samp.feat_names{6} = 's1_width';
    samp.feat_vals(6) = s1.r - s1.l + 1;
    samp.feat_names{7} = 's2_width';
    samp.feat_vals(7) = s2.r - s2.l + 1;
    samp.feat_names{8} = 'ws_width';
    samp.feat_vals(8) = ws.r - ws.l + 1;
    samp.feat_names{9} = 's0_area';
    samp.feat_vals(9) = (s0.b - s0.t + 1) * (s0.r - s0.l + 1);
    samp.feat_names{10} = 's1_area';
    samp.feat_vals(10) = (s1.b - s1.t + 1) * (s1.r - s1.l + 1);
    samp.feat_names{11} = 's2_area';
    samp.feat_vals(11) = (s2.b - s2.t + 1) * (s2.r - s2.l + 1);
    samp.feat_names{12} = 'ws_area';
    samp.feat_vals(12) = (ws.b - ws.t + 1) * (ws.r - ws.l + 1);

    samp.feat_names{13} = 'cuts_full_page';
    if (samp.horizontal);
        wsbox = pix(ws.t:ws.b, 1:size(pix,2));
        if (min(max(1-wsbox')) == 0);
            samp.feat_vals(13) = 1;
        else;
            samp.feat_vals(13) = 0;
        end;
    else;
        wsbox = pix(1:size(pix,1),ws.l:ws.r);
        if (min(max(1-wsbox)) == 0);
            samp.feat_vals(13) = 1;
        else;
            samp.feat_vals(13) = 0;
        end;
    end;

    samp.feat_names{14} = 's0.dens';
    samp.feat_vals(14) = mean(mean(1-pix(s0.t:s0.b,s0.l:s0.r)));
    samp.feat_names{15} = 's1.dens';
    samp.feat_vals(15) = mean(mean(1-pix(s1.t:s1.b,s1.l:s1.r)));
    samp.feat_names{16} = 's2.dens';
    samp.feat_vals(16) = mean(mean(1-pix(s2.t:s2.b,s2.l:s2.r)));
    
    samp.feat_names{17} = 'h_reduction';
    samp.feat_vals(17) = (s0.r-s0.l+1) - min([(s1.r-s1.l+1),(s2.r-s2.l+1)]);

    samp.feat_names{18} = 'v_reduction';
    samp.feat_vals(18) = (s0.b-s0.t+1) - min([(s1.b-s1.t+1),(s2.b-s2.t+1)]);

    samp.feat_names{19} = 's0.l';
    samp.feat_vals(19) = s0.l;
    samp.feat_names{20} = 's0.r';
    samp.feat_vals(20) = s0.r;
    samp.feat_names{21} = 's0.t';
    samp.feat_vals(21) = s0.t;
    samp.feat_names{22} = 's0.b';
    samp.feat_vals(22) = s0.b;

    samp.feat_names{23} = 's1.l';
    samp.feat_vals(23) = s1.l;
    samp.feat_names{24} = 's1.r';
    samp.feat_vals(24) = s1.r;
    samp.feat_names{25} = 's1.t';
    samp.feat_vals(25) = s1.t;
    samp.feat_names{26} = 's1.b';
    samp.feat_vals(26) = s1.b;

    samp.feat_names{27} = 's2.l';
    samp.feat_vals(27) = s2.l;
    samp.feat_names{28} = 's2.r';
    samp.feat_vals(28) = s2.r;
    samp.feat_names{29} = 's2.t';
    samp.feat_vals(29) = s2.t;
    samp.feat_names{30} = 's2.b';
    samp.feat_vals(30) = s2.b;

    for j=1:size(pnum_feats,2);
        samp.feat_names{30 + j} = pnum_feats(j).name;
        samp.feat_vals(30 + j) = pnum_feats(j).val;
    end;
    samps = [samps,samp];
end;



