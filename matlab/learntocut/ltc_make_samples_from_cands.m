function samps = ltc_make_samples_from_cands(candidates, pix);
samps = [];

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


    samps = [samps,samp];
end;


