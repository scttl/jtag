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

%fprintf('Starting with [%i,%i,%i,%i]\n', live_segs(1), live_segs(2), ...
%        live_segs(3), live_segs(4));

%Next, the horizontal full pass on each live_seg
[live_segs,ds] = seg_pass(ww,live_segs,pixels,1,1,jt);
dead_segs = [dead_segs;ds];

%fprintf('After pass 1, live segs:\n');
%disp(live_segs);
%fprintf('After pass 1, dead segs:\n');
%disp(dead_segs);

[live_segs,ds] = seg_pass(ww,live_segs,pixels,0,0,jt);
dead_segs = [dead_segs;ds];

%fprintf('After pass 2, live segs:\n');
%disp(live_segs);
%fprintf('After pass 2, dead segs:\n');
%disp(dead_segs);

[live_segs,ds] = seg_pass(ww,live_segs,pixels,1,0,jt);
dead_segs = [dead_segs;ds];

%fprintf('After pass 3, live segs:\n');
%disp(live_segs);
%fprintf('After pass 3, dead segs:\n');
%disp(dead_segs);

useslope = 30;
segs = [live_segs;dead_segs];
[junk,segorder] = sort((useslope * segs(:,2)) + segs(:,4));
segs = segs(segorder,:);


%------------------------------------------------------
%---Subfunction Declarations---------------------------
function [live_segs,dead_segs] = seg_pass(ww,live_segs,pix,h,f,jt);

cut_classes = {'no','yes'};

done_segs = [];
dead_segs = [];
while (length(live_segs) > 0);
    %fprintf('Pass with live_segs=\n');
    %disp(live_segs);
    valid_cuts = [];
    paths = [];
    seg = live_segs(1,:);
    live_segs(1,:) = [];

    %Get the cut candidates
    cut_cands = ltc3_find_cand(pix,seg);
    if (length(cut_cands) > 0);
        cut_cands = cut_cands(find([cut_cands.horizontal]==h));
        cut_samps = ltc3_make_samples_from_cands(cut_cands,pix,jt,h,f,seg);
    end;
    %fprintf('Found %i cut cands.\n',length(cut_cands));

    %Evaluate the candidates
    for i=1:length(cut_cands);
        samp = cut_samps(i);
        cand = cut_cands(i);
        [score_y,score_n] = ltc3_score_seg(samp,ww);
        %fprintf('Cand %i: y=%f, n=%f\n',i,score_y,score_n);
        if (score_y > score_n);
            samp.valid_cut = true;
            cand.valid_cut = true;
            valid_cuts = [valid_cuts;cand];
        end;
    end;
    %fprintf('Of which, %i were valid.\n',length(valid_cuts));
    
    %Make the valid cuts
    if (length(valid_cuts) > 0);
        done_segs = [done_segs;make_cuts(seg,valid_cuts,pix)];
    elseif (f && ~h);
        done_segs = [done_segs; seg];
    else;
        dead_segs = [dead_segs;seg];
    end;
    
end;

live_segs = done_segs;

%fprintf('After pass, live_segs=\n');
%disp(live_segs);
