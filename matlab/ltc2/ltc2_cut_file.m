function segs = ltc2_cut_file(jt,weights,pix);
% function segs = ltc2_cut_file(jt,weights,pix);
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
while (length(live_segs) > 0);
    paths = [];
    seg = live_segs(1,:);
    live_segs(1,:) = [];

    %Get the cut candidates
    cut_cands = ltc2_find_cand(pix,seg);
    cut_cands = pad_cut_cands(cut_cands);

    %Create a "path" and "score" with just the first candidate set to 1.
    path.cuts = cut_cands(1);
    path.score_sum = 0;
    paths = [paths;path];
    %For each candidate, find the best path up to it when it is a 1:
    for i=2:length(cut_cands);
        cut_cand = cut_cands(i);
        %For each "path" in our list, check if it creates the best path in
        %which this candidate is a 1:
        bestscore = -inf;
        bestpath = [];
        for j=1:length(paths);
            path = paths(j);
            
            %Add this cut to the "path", and re-score it.
            path.cuts = [path.cuts;cut_cand];
            if (h);
                seg_cand.rects=[seg(1),path.cuts(end).y,seg(3),cut_cand.y];
            else;
                seg_cand.rects=[path.cuts(end).x,seg(2),cut_cand.x,seg(4)];
            end;
            seg_cand.rects = seg_snap(seg_cand.rects, pix, 0);
            seg_cand.segs_valid = 1;
            seg_samp = ltc2_make_samples_from_cands(seg_cand,pix,jt,h,f,seg);
            cand_score = ltc2_score_samp(seg_samp,weights.whf);
            path.score_sum = path.score_sum + cand_score;
            if (path.score_sum / (length(path.cuts)-1)) > bestscore;
                bestpath = path;
                bestscore = path.score_sum / (length(path.cuts)-1);
            end;
        end;
        paths = [paths;bestpath];
    end;
    cut_cands = cut_cands(2:end-1);   %Un-pad the cut_cands
    if (length(cut_cands)>0);
        done_segs = [done_segs; make_cuts(seg,bestpath.cuts,pix)];
    elseif (f && ~h);
        done_segs = [done_segs; seg];
    else;
        dead_segs = [dead_segs; seg];
    end;
end;


