function [samps,fnames] = ltc3_make_samples_from_cands(cut_cands,pix,jt,h,f,cs);
%
% function [samps,fnames] = ltc3_make_samples_from_cands(cut_cands, pix, jt, 
%                                                        h, f);
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

%All descriptions are given assuming a horizontal cut.  The translations to
%vertical cuts are simple and intuitive.
fnames = {'cut_width'; ...      %How wide of a valley is being cut
          'cut_length'; ...     %How long is the cut
          'cut_area'; ...       %Total cut area (width * height)
          'avg_ws'; ...         %Average whitespace in a block extended 80
                                %pixels above & below cut.
          'total_ws'; ...       %Total whitespace in a block extended 80
                                %pixels above & below cut
          'pct_ws_line-20'; ... %Pct whitespace on row 20 pixels above cut
          'pct_ws_line-19'; ... %Pct whitespace on row 19 pixels above cut
          'pct_ws_line-18'; ... %Pct whitespace on row 18 pixels above cut
          'pct_ws_line-17'; ... %Pct whitespace on row 17 pixels above cut
          'pct_ws_line-16'; ... %Pct whitespace on row 16 pixels above cut
          'pct_ws_line-15'; ... %Pct whitespace on row 15 pixels above cut
          'pct_ws_line-14'; ... %Pct whitespace on row 14 pixels above cut
          'pct_ws_line-13'; ... %Pct whitespace on row 13 pixels above cut
          'pct_ws_line-12'; ... %Pct whitespace on row 12 pixels above cut
          'pct_ws_line-11'; ... %Pct whitespace on row 11 pixels above cut
          'pct_ws_line-10'; ... %Pct whitespace on row 10 pixels above cut
          'pct_ws_line-9'; ...  %Pct whitespace on row 9 pixels above cut
          'pct_ws_line-8'; ...  %Pct whitespace on row 8 pixels above cut
          'pct_ws_line-7'; ...  %Pct whitespace on row 7 pixels above cut
          'pct_ws_line-6'; ...  %Pct whitespace on row 6 pixels above cut
          'pct_ws_line-5'; ...  %Pct whitespace on row 5 pixels above cut
          'pct_ws_line-4'; ...  %Pct whitespace on row 4 pixels above cut
          'pct_ws_line-3'; ...  %Pct whitespace on row 3 pixels above cut
          'pct_ws_line-2'; ...  %Pct whitespace on row 2 pixels above cut
          'pct_ws_line-1'; ...  %Pct whitespace on row 1 pixels above cut
          'pct_ws_line0';  ...  %pct whitespace on row of cut
          'pct_ws_line+1'; ...  %Pct whitespace on row 1 pixels below cut
          'pct_ws_line+2'; ...  %Pct whitespace on row 2 pixels below cut
          'pct_ws_line+3'; ...  %Pct whitespace on row 3 pixels below cut
          'pct_ws_line+4'; ...  %Pct whitespace on row 4 pixels below cut
          'pct_ws_line+5'; ...  %Pct whitespace on row 5 pixels below cut
          'pct_ws_line+6'; ...  %Pct whitespace on row 6 pixels below cut
          'pct_ws_line+7'; ...  %Pct whitespace on row 7 pixels below cut
          'pct_ws_line+8'; ...  %Pct whitespace on row 8 pixels below cut
          'pct_ws_line+9'; ...  %Pct whitespace on row 9 pixels below cut
          'pct_ws_line+10'; ... %Pct whitespace on row 10 pixels below cut
          'pct_ws_line+11'; ... %Pct whitespace on row 11 pixels below cut
          'pct_ws_line+12'; ... %Pct whitespace on row 12 pixels below cut
          'pct_ws_line+13'; ... %Pct whitespace on row 13 pixels below cut
          'pct_ws_line+14'; ... %Pct whitespace on row 14 pixels below cut
          'pct_ws_line+15'; ... %Pct whitespace on row 15 pixels below cut
          'pct_ws_line+16'; ... %Pct whitespace on row 16 pixels below cut
          'pct_ws_line+17'; ... %Pct whitespace on row 17 pixels below cut
          'pct_ws_line+18'; ... %Pct whitespace on row 18 pixels below cut
          'pct_ws_line+19'; ... %Pct whitespace on row 19 pixels below cut
          'pct_ws_line+20'; ... %Pct whitespace on row 20 pixels below cut
          'pct_ws_end'; ...   %Pct whitespace in block of the 20% last columns,
                              %in the cut, extended 80 pixels up & down 
                              %from the cut point.
          'pct_ws_mid'; ...   %Pct whitespace in block of the 20% middle
                              %columns in the cut, extended 80 pixels up &
                              %down from the cut point.
          'pct_ws_start'}; ... %Pct whitespace in block of the 20% first 
                               %columns, in the cut, extended 80 pixels up &
                               %down from the cut point.

for j=1:size(pnum_feats,2);
    fnames{length(fnames)+1} = pnum_feats(j).name;
end;

if (nargin == 0);
    return;
end;


for i=1:length(cut_cands);
    cand = cut_cands(i);
    clear samp;

    samp.horizontal = h;
    samp.fullpage = f;
    if (isfield(cand,'valid_cut'));
        samp.valid_cut = cand.valid_cut;
    end;
    samp.x = cand.x;
    samp.y = cand.y;
    samp.feat_vals = [];

    s0.l = cand.seg_left;
    s0.r = cand.seg_right;
    s0.t = cand.seg_top;
    s0.b = cand.seg_bot;
    
    if ~h; %This is a vertical cut
        x = cand.x;
        s1box = [s0.l, s0.t, max(cand.x-1,1), s0.b];
        s1box = seg_snap(pix,s1box,0);
        s2box = [min(cand.x+1,size(pix,2)), s0.t, s0.r, s0.b];
        s2box = seg_snap(pix,s2box,0);
        ws.l = s1box(3) + 1;
        ws.r = s2box(1) - 1;
        ws.t = s0.t;
        ws.b = s0.b;

        %'cut_width'; ...      %How wide of a valley is being cut
        samp.feat_vals(length(samp.feat_vals)+1) = (ws.r-ws.l+1);
        %'cut_length'; ...     %How long is the cut
        samp.feat_vals(length(samp.feat_vals)+1) = (ws.b-ws.t+1);
        %'cut_area'; ...       %Total cut area (width * height)
        samp.feat_vals(length(samp.feat_vals)+1) = (ws.r-ws.l+1)*(ws.b-ws.t+1);

        %'avg_ws'; ...         %Average whitespace in a block extended 80
        %                      %pixels above & below cut.
        subpix = pix(ws.t:ws.b,max(ws.l-80,1):min(ws.r+80,size(pix,2)));
        x = cand.x - max(ws.l-80,1);
        l_pix = subpix(1:end,1:x-1);
        di_left = [ones(1,120),1,zeros(1,120)];
        l_pix = 1-imdilate(1-l_pix,di_left);
        ws_sum = length(find(l_pix));
        r_pix = subpix(1:end,x+1:end);
        di_right = [zeros(1,120),1,ones(1,120)];
        r_pix = 1-imdilate(1-r_pix,di_right);
        ws_sum = ws_sum + length(find(r_pix));

        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum / size(subpix,1);
        
        %'total_ws'; ...       %Total whitespace in a block extended 80
        %                      %pixels above & below cut
        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum;

        %'pct_ws_line-20'; ... %Pct whitespace on row 20 pixels above cut
        for i=-20:20;
            if ((x+i) >= 1) && ((x+i) <= size(pix,1));
                ws_row = mean(pix(ws.t:ws.b,x+i));
            else;
                ws_row = 1;
            end;
            samp.feat_vals(length(samp.feat_vals)+1) = ws_row;
        end;

        %'pct_ws_end'; ...   %Pct whitespace in block of the 20% last columns,
        %                  %in the cut, extended 80 pixels up & down 
        %                  %from the cut point.
        pct_20 = floor((ws.b-ws.t+1) * 0.2);
        samp.feat_vals(length(samp.feat_vals)+1) = ...
            mean(mean(pix(ws.b-pct_20:ws.b, ...
                          max(1,x-80):min(size(pix,2),x+80))));


        %'pct_ws_mid'; ...   %Pct whitespace in block of the 20% middle
        %                  %columns in the cut, extended 80 pixels up &
        %                  %down from the cut point.
        midpt = floor((ws.t+ws.b)/2);
        samp.feat_vals(length(samp.feat_vals)+1) = ...
            mean(mean(pix(midpt-floor(pct_20/2):midpt+floor(pct_20/2), ...
                          max(1,x-80):min(size(pix,2),x+80))));

        %'pct_ws_start'}; ... %Pct whitespace in block of the 20% first 
        %                   %columns, in the cut, extended 80 pixels up &
        %                   %down from the cut point.
        samp.feat_vals(length(samp.feat_vals)+1) = ...
            mean(mean(pix(ws.t:ws.t+pct_20, ...
                          max(1,x-80):min(size(pix,2),x+80))));
        
    else;  %This is a horizontal cut
        y = cand.y;
        s1box = [s0.l, s0.t, s0.r, max(cand.y-1,1)];
        s1box = seg_snap(pix,s1box,0);
        s2box = [s0.l, min(cand.y+1,size(pix,1)), s0.r, s0.b];
        s2box = seg_snap(pix,s2box,0);
        ws.l = s0.l;
        ws.r = s0.r;
        ws.t = s1box(4) + 1;
        ws.b = s2box(2) - 1;

        %'cut_width'; ...      %How wide of a valley is being cut
        samp.feat_vals(length(samp.feat_vals)+1) = (ws.b-ws.t+1);
        %'cut_length'; ...     %How long is the cut
        samp.feat_vals(length(samp.feat_vals)+1) = (ws.r-ws.l+1);
        %'cut_area'; ...       %Total cut area (width * height)
        samp.feat_vals(length(samp.feat_vals)+1) = (ws.r-ws.l+1)*(ws.b-ws.t+1);

        %'avg_ws'; ...         %Average whitespace in a block extended 80
        %                      %pixels above & below cut.
        subpix = pix(max(ws.t-80,1):min(ws.b+80,size(pix,1)), ws.l:ws.r);
        y = cand.y-max(ws.t-80,1)+1;

        top_pix = subpix(1:y-1,1:end);
        di_up = [ones(120,1);1;zeros(120,1)];
        top_pix = 1-imdilate(1-top_pix,di_up);
        ws_sum = length(find(top_pix));
        
        bot_pix = subpix(y+1:end,1:end);
        di_down = [zeros(120,1);1;ones(120,1)];
        bot_pix = 1-imdilate(1-bot_pix,di_down);
        ws_sum = ws_sum + length(find(bot_pix));

        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum / size(subpix,2);
        
        %'total_ws'; ...       %Total whitespace in a block extended 80
        %                      %pixels above & below cut
        samp.feat_vals(length(samp.feat_vals)+1) = ws_sum;

        %'pct_ws_line-20'; ... %Pct whitespace on row 20 pixels above cut
        for i=-20:20;
            if ((y+i) >= 1) && ((y+i) <= size(pix,2));
                ws_row = mean(pix(y+i,ws.l:ws.r));
            else;
                ws_row = 1;
            end;
            samp.feat_vals(length(samp.feat_vals)+1) = ws_row;
        end;

        %'pct_ws_end'; ...   %Pct whitespace in block of the 20% last columns,
        %                  %in the cut, extended 80 pixels up & down 
        %                  %from the cut point.
        pct_20 = floor((ws.r-ws.l+1) * 0.2);
        samp.feat_vals(length(samp.feat_vals)+1) = ...
            mean(mean(pix(max(1,y-80):min(y+80,size(pix,1)), ...
                          (ws.r-pct_20):ws.r)));
        
        %'pct_ws_mid'; ...   %Pct whitespace in block of the 20% middle
        %                  %columns in the cut, extended 80 pixels up &
        %                  %down from the cut point.
        midpt = floor((ws.l+ws.r)/2);
        samp.feat_vals(length(samp.feat_vals)+1) = ...
            mean(mean(pix(max(1,y-80):min(y+80,size(pix,1)), ...
                          midpt-floor(pct_20/2):midpt+floor(pct_20/2))));

        %'pct_ws_start'}; ... %Pct whitespace in block of the 20% first 
        %                   %columns, in the cut, extended 80 pixels up &
        %                   %down from the cut point.
        samp.feat_vals(length(samp.feat_vals)+1) = ...
            mean(mean(pix(max(1,y-80):min(y+80,size(pix,1)), ...
                          ws.l:ws.l+pct_20)));
    end;
    
    for j=1:size(pnum_feats,2);
        samp.feat_vals(length(samp.feat_vals)+1) = pnum_feats(j).val;
    end;

    samps = [samps;samp];
end;

