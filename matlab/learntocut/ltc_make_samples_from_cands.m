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
    samp.feat_names = [];
    samp.feat_vals = [];

    samp.feat_names{length(samp.feat_names)+1} = 's0_height';
    samp.feat_vals(length(samp.feat_vals)+1) = s0.b - s0.t + 1;
    samp.feat_names{length(samp.feat_names)+1} = 's1_height';
    samp.feat_vals(length(samp.feat_vals)+1) = s1.b - s1.t + 1;
    samp.feat_names{length(samp.feat_names)+1} = 's2_height';
    samp.feat_vals(length(samp.feat_vals)+1) = s2.b - s2.t + 1;
    samp.feat_names{length(samp.feat_names)+1} = 'ws.height';
    samp.feat_vals(length(samp.feat_vals)+1) = ws.b - ws.t + 1;
    samp.feat_names{length(samp.feat_names)+1} = 's0_width';
    samp.feat_vals(length(samp.feat_vals)+1) = s0.r - s0.l + 1;
    samp.feat_names{length(samp.feat_names)+1} = 's1_width';
    samp.feat_vals(length(samp.feat_vals)+1) = s1.r - s1.l + 1;
    samp.feat_names{length(samp.feat_names)+1} = 's2_width';
    samp.feat_vals(length(samp.feat_vals)+1) = s2.r - s2.l + 1;
    samp.feat_names{length(samp.feat_names)+1} = 'ws_width';
    samp.feat_vals(length(samp.feat_vals)+1) = ws.r - ws.l + 1;
    samp.feat_names{length(samp.feat_names)+1} = 's0_area';
    samp.feat_vals(length(samp.feat_vals)+1) = (s0.b - s0.t + 1) * (s0.r - s0.l + 1);
    samp.feat_names{length(samp.feat_names)+1} = 's1_area';
    samp.feat_vals(length(samp.feat_vals)+1) = (s1.b - s1.t + 1) * (s1.r - s1.l + 1);
    samp.feat_names{length(samp.feat_names)+1} = 's2_area';
    samp.feat_vals(length(samp.feat_vals)+1) = (s2.b - s2.t + 1) * (s2.r - s2.l + 1);
    samp.feat_names{length(samp.feat_names)+1} = 'ws_area';
    samp.feat_vals(length(samp.feat_vals)+1) = (ws.b - ws.t + 1) * (ws.r - ws.l + 1);

    samp.feat_names{length(samp.feat_names)+1} = 'cuts_full_page';
    if (samp.horizontal);
        wsbox = pix(ws.t:ws.b, 1:size(pix,2));
        if (min(max(1-wsbox')) == 0); %If any row is white all the way across
            samp.feat_vals(length(samp.feat_vals)+1) = 1;
        else;
            samp.feat_vals(length(samp.feat_vals)+1) = 0;
        end;
    else;
        wsbox = pix(1:size(pix,1),ws.l:ws.r);
        if (min(max(1-wsbox)) == 0); %If any col is white all the way across
            samp.feat_vals(length(samp.feat_vals)+1) = 1;
        else;
            samp.feat_vals(length(samp.feat_vals)+1) = 0;
        end;
    end;

    samp.feat_names{length(samp.feat_names)+1} = 's0.dens';
    samp.feat_vals(length(samp.feat_vals)+1) = mean(mean(1-pix(s0.t:s0.b,s0.l:s0.r)));
    samp.feat_names{length(samp.feat_names)+1} = 's1.dens';
    samp.feat_vals(length(samp.feat_vals)+1) = mean(mean(1-pix(s1.t:s1.b,s1.l:s1.r)));
    samp.feat_names{length(samp.feat_names)+1} = 's2.dens';
    samp.feat_vals(length(samp.feat_vals)+1) = mean(mean(1-pix(s2.t:s2.b,s2.l:s2.r)));
    
    samp.feat_names{length(samp.feat_names)+1} = 'h_reduction';
    samp.feat_vals(length(samp.feat_vals)+1) = (s0.r-s0.l+1) - min([(s1.r-s1.l+1),(s2.r-s2.l+1)]);

    samp.feat_names{length(samp.feat_names)+1} = 'v_reduction';
    samp.feat_vals(length(samp.feat_vals)+1) = (s0.b-s0.t+1) - min([(s1.b-s1.t+1),(s2.b-s2.t+1)]);

    samp.feat_names{length(samp.feat_names)+1} = 's0.l';
    samp.feat_vals(length(samp.feat_vals)+1) = s0.l;
    samp.feat_names{length(samp.feat_names)+1} = 's0.r';
    samp.feat_vals(length(samp.feat_vals)+1) = s0.r;
    samp.feat_names{length(samp.feat_names)+1} = 's0.t';
    samp.feat_vals(length(samp.feat_vals)+1) = s0.t;
    samp.feat_names{length(samp.feat_names)+1} = 's0.b';
    samp.feat_vals(length(samp.feat_vals)+1) = s0.b;

    samp.feat_names{length(samp.feat_names)+1} = 's1.l';
    samp.feat_vals(length(samp.feat_vals)+1) = s1.l;
    samp.feat_names{length(samp.feat_names)+1} = 's1.r';
    samp.feat_vals(length(samp.feat_vals)+1) = s1.r;
    samp.feat_names{length(samp.feat_names)+1} = 's1.t';
    samp.feat_vals(length(samp.feat_vals)+1) = s1.t;
    samp.feat_names{length(samp.feat_names)+1} = 's1.b';
    samp.feat_vals(length(samp.feat_vals)+1) = s1.b;

    samp.feat_names{length(samp.feat_names)+1} = 's2.l';
    samp.feat_vals(length(samp.feat_vals)+1) = s2.l;
    samp.feat_names{length(samp.feat_names)+1} = 's2.r';
    samp.feat_vals(length(samp.feat_vals)+1) = s2.r;
    samp.feat_names{length(samp.feat_names)+1} = 's2.t';
    samp.feat_vals(length(samp.feat_vals)+1) = s2.t;
    samp.feat_names{length(samp.feat_names)+1} = 's2.b';
    samp.feat_vals(length(samp.feat_vals)+1) = s2.b;

    for j=1:size(pnum_feats,2);
        samp.feat_names{length(samp.feat_names)+1} = pnum_feats(j).name;
        samp.feat_vals(length(samp.feat_vals)+1) = pnum_feats(j).val;
    end;

    samp.feat_names{length(samp.feat_names)+1} = 'avg_ws';
    ws_sum = 0;

    
    if (samp.horizontal);
        subpix = pix(max(ws.t-80,1):min(ws.b+80,size(pix,1)), ws.l:ws.r);
        y = cand.y-max(ws.t-80,1)+1;

        top_pix = subpix(1:y-1,1:end);
        di_up = [ones(120,1);1;zeros(120,1)];
        top_pix = 1-imdilate(1-top_pix,di_up);
        ws_sum = ws_sum + length(find(top_pix));
        
        bot_pix = subpix(y+1:end,1:end);
        di_down = [zeros(120,1);1;ones(120,1)];
        bot_pix = 1-imdilate(1-bot_pix,di_down);
        ws_sum = ws_sum + length(find(bot_pix));

        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum / size(subpix,2);
    else; %Must be vertical
        subpix = pix(ws.t:ws.b,max(ws.l-80,1):min(ws.r+80,size(pix,2)));
        x = cand.x - max(ws.l-80,1);

        l_pix = subpix(1:end,1:x-1);
        di_left = [ones(1,120),1,zeros(1,120)];
        l_pix = 1-imdilate(1-l_pix,di_left);
        ws_sum = ws_sum + length(find(l_pix));
        
        r_pix = subpix(1:end,x+1:end);
        di_right = [zeros(1,120),1,ones(1,120)];
        r_pix = 1-imdilate(1-r_pix,di_right);
        ws_sum = ws_sum + length(find(r_pix));

        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum / size(subpix,1);
    end;
        



%    
%    if (samp.horizontal);
%        subpix = pix(max(ws.t-80,1):min(ws.b+80,size(pix,1)), ws.l:ws.r);
%        y = cand.y-max(ws.t-80,1)+1;
%        top_pix = subpix(1:y-1,1:end);
%        bot_pix = subpix(y+1:end,1:end);
%        for i=1:size(subpix,2);
%            row = top_pix(1:end,i);
%            row_ink = find(1-row);
%            if (length(row_ink) > 0);
%                row_ws = size(top_pix,1) - row_ink(end);
%            else;
%                row_ws = 0;
%            end;
%            ws_sum = ws_sum + (row_ws);
%            row = bot_pix(1:end,i);
%            row_ink = find(1-bot_pix);
%            if (length(row_ink) > 0);
%                row_ws = row_ink(1);
%            else;
%                row_ws = 0;
%            end;
%            ws_sum = ws_sum + (row_ws);
%        end;
%        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum / size(subpix,2);
%    else; %Must be vertical
%        subpix = pix(ws.t:ws.b,max(ws.l-80,1):min(ws.r+80,size(pix,2)));
%        x = cand.x - max(ws.l-80,1);
%        l_pix = subpix(1:end,1:x-1);
%        r_pix = subpix(1:end,x+1:end);
%        for i=1:size(subpix,1);
%            col = l_pix(i,1:end);
%            col_ink = find(1-col);
%            if (length(col_ink) > 0);
%                col_ws = size(l_pix,2) - col_ink(end);
%            else;
%                col_ws = 0;
%            end;
%            ws_sum = ws_sum + col_ws;
%            col = r_pix(i,1:end);
%            col_ink = find(1-col);
%            if (length(col_ink) > 0);
%                col_ws = col_ink(1);
%            else;
%                col_ws = 0;
%            end;
%            ws_sum = ws_sum + col_ws;
%        end;
%        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum / size(subpix,1);
%    end;
%        
    samps = [samps,samp];
end;



