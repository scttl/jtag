function segs = ltc3_cut_file(jt,weights,pix);
% function segs = ltc3_cut_file(jt,weights,pix);
%
% -pix are the result of imread(filepath).
%      -pix(y,x)

if (nargin < 3);
    pixels = imread(jt.img_file);
else;
    pixels = pix;
end;

if (ischar(weights));
    ww = parse_lr_weights(weights);
else;
    ww = weights;
end;

% segs = [Left Top Bottom Right
%         Left Top Bottom Right
%         ...]
start_seg = [1 1 size(pixels,2) size(pixels,1)];
start_seg = seg_snap(pixels, start_seg, 0);

live_segs = start_seg;

dead_segs = [];


%First, the vertical full pass
%Not used

%Next, the horizontal full pass on each live_seg
[live_segs,ds] = seg_pass(ww,live_segs,pix,1,1);
dead_segs = [dead_segs;ds];

[live_segs,ds] = seg_pass(ww,live_segs,pix,0,0);
dead_segs = [dead_segs;ds];

[live_segs,ds] = seg_pass(ww,live_segs,pix,1,0);
dead_segs = [dead_segs;ds];

useslope = 30;
segs = [live_segs;dead_segs];
[junk,segorder] = sort((useslope * segs(:,2)) + segs(:,4));
segs = segs(segorder,:);


%------------------------------------------------------
%---Subfunction Declarations---------------------------
function [live_segs,dead_segs] = seg_pass(ww,live_segs,pix,h,f);

cut_classes = {'no','yes'};

done_segs = [];
dead_segs = [];
valid_cuts = [];
while (length(live_segs) > 0);
    paths = [];
    seg = live_segs(1,:);
    live_segs(1,:) = [];

    %Get the cut candidates
    cut_cands = ltc3_find_cand(pix,seg);
    cut_samps = ltc3_make_samples_from_cands(cut_cands,pix,jt,h,f,seg);

    %Evaluate the candidates
    for i=1:length(cut_samps);
        samp = cut_samps(i);
        cand = cut_cands(i);
        [score_y,score_n] = ltc3_score_samp(samp,ww);
        if (score_y > score_n);
            samp.valid_cut = true;
            cand.valid_cut = true;
            valid_cuts = [valid_cuts;cand];
        end;
    end;
    
    %Make the valid cuts
    if (length(valid_cuts) > 0);
        done_segs = [done_segs;make_cuts(seg,valid_cuts,pix)];
    elseif (f && ~h);
        done_segs = [done_segs; seg];
    else;
        dead_segs = [dead_segs;seg];
    end;
    
end;


