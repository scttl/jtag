function segs = ltc2_cut_file(jt,weights,pix);
% function segs = ltc2_cut_file(jt,weights,pix);
%
% -pix are the result of imread(filepath).
%      -pix(y,x)

tic;

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
[live_segs,ds] = seg_pass(ww,live_segs,pix,1,1,jt);
dead_segs = [dead_segs;ds];

[live_segs,ds] = seg_pass(ww,live_segs,pix,0,0,jt);
dead_segs = [dead_segs;ds];

[live_segs,ds] = seg_pass(ww,live_segs,pix,1,0,jt);
dead_segs = [dead_segs;ds];

useslope = 30;
segs = [live_segs;dead_segs];
[junk,segorder] = sort((useslope * segs(:,2)) + segs(:,4));
segs = segs(segorder,:);


%------------------------------------------------------
%---Subfunction Declarations---------------------------
function [live_segs,dead_segs] = seg_pass(ww,live_segs,pix,h,f,jt);
fprintf('Starting pass h=%i, f=%i, time=%i\n',h,f,toc);
cut_classes = {'no','yes'};

done_segs = [];
dead_segs = [];
while (length(live_segs) > 0);
    fprintf('    %i segs remaining, time=%i.\n',size(live_segs,1), toc);
    paths = [];
    seg = live_segs(1,:);
    live_segs(1,:) = [];

    %Get the cut candidates
    cut_cands = ltc2_find_cand(pix,seg);
    if (length(cut_cands) > 0);
        cut_cands = cut_cands(find([cut_cands.horizontal]==h));
    end;
    fprintf('        Found %i cut_cands at t=%i\n',length(cut_cands),toc);
    if (length(cut_cands) == 0);
        dead_segs = [dead_segs;seg];
        continue;
    end;

    %Find the seg candidates
    [seg_cands,cut_cands] = cuts_to_segs(seg,cut_cands,pix,h,0);
    fprintf('        Found %i seg_cands, t=%i\n', ...
            length(seg_cands.segs_valid),toc);
    seg_samps = ltc2_make_samples_from_cands(seg_cands,pix,jt,h,f,seg);
    fprintf('        Found %i seg_samps, t=%i\n',length(seg_samps),toc);

    %Score the seg candidates, creating a score matrix
    seg_ll_y = zeros(length(cut_cands));
    seg_ll_n = zeros(length(cut_cands));
    for i=1:length(seg_cands.segs_valid);
        [y,n] = ltc2_score_seg(seg_samps(i),ww);
        seg_ll_y(seg_samps(i).cut_before,seg_samps(i).cut_after) = y;
        seg_ll_n(seg_samps(i).cut_before,seg_samps(i).cut_after) = n;
    end;
    fprintf('        Scored all seg_samps, t=%i.\n',toc);
    

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

        seg_ll_ops_y = seg_ll_y(:,i);
        seg_ll_ops_n = seg_ll_n(:,i);
        
        for j=1:length(paths);
            path = paths(j);
            
            %Add this cut to the "path", and re-score it.
            path.cuts = [path.cuts;cut_cand];
            cutno = path.cuts(end).index;
            path.score_sum = path.score_sum + seg_ll_ops_y(cutno) + ...
                             sum(seg_ll_ops_n(1:cutno-1)) + ...
                             sum(seg_ll_ops_n(cutno+1:end));
            if (path.score_sum) > bestscore;
                bestpath = path;
                bestscore = path.score_sum;
            end;
        end;
        paths = [paths;bestpath];
    end;
    %cut_cands = cut_cands(2:end-1);   %Un-pad the cut_cands
    if (length(cut_cands)>0);
        done_segs = [done_segs; make_cuts(seg,bestpath.cuts,pix)];
    elseif (f && ~h);
        done_segs = [done_segs; seg];
    else;
        dead_segs = [dead_segs; seg];
    end;
end;

live_segs = done_segs;
