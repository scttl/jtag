function segs = ltc_cut_file(jt,weights,pix);
% function segs = ltc_cut_file(jt,weights,pix);
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

done_segs = [];

cut_classes = {'v_no','v_yes','UNUSED','UNUSED', ...
               'h_part_no','h_part_yes','h_full_no','h_full_yes'};

its = 0;
while (~ isempty(live_segs));
    its = its + 1;
    %fprintf('In iteration %i, lives_segs=\n',its);
    %disp(live_segs);
    cs = live_segs(1,:);
    %fprintf('Checking [%i %i %i %i] for cuts.\n',cs(1),cs(2),cs(3),cs(4));
    candidates = ltc_find_cand(pixels, live_segs(1,:));
    if (length(candidates) > 0);
        ch = candidates(find([candidates.horizontal]));
        cv = candidates(find(1 - [candidates.horizontal]));
    else;
        ch = [];
        cv = [];
    end;
    if (length(ch) > 0);
        sh = ltc_make_samples_from_cands(ch,pixels,jt);
        h_feats = reshape([sh.feat_vals], ...
                          length(sh(1).feat_vals),length(sh));
        h_cids = lr_fn(cut_classes(5:8),h_feats','null',ww.wh) + 3;
        for i=1:length(sh);
            sh(i).valid_cut = mod(h_cids(i),2);
            sh(i).fullpage = mod(floor(h_cids(i)/2),2);
            ch(i).valid_cut = sh(i).valid_cut;
            ch(i).fullpage = sh(i).fullpage;
        end;
        h_scores = ltc_rank_cands(pixels, live_segs(1,:), ch);
    else;
        h_scores = [];
    end;

    if (length(cv) > 0);
        sv = ltc_make_samples_from_cands(cv,pixels,jt);
        v_feats = reshape([sv.feat_vals], ...
                          length(sv(1).feat_vals),length(sv));
        v_cids = lr_fn(cut_classes(1:2),v_feats','null',ww.wv) - 1;
        for i=1:length(sv);
            sv(i).valid_cut = mod(v_cids(i),2);
            sv(i).fullpage = mod(floor(v_cids(i)/2),2);
            cv(i).valid_cut = sv(i).valid_cut;
            cv(i).fullpage = sv(i).fullpage;
        end;
        v_scores = ltc_rank_cands(pixels, live_segs(1,:), cv);
    else;
        v_scores = [];
    end;

    scores = [h_scores, v_scores];
    cands = [];
    if (length(ch) > 0);
        cands = [cands,ch];
    end;
    if (length(cv) > 0);
        cands = [cands, cv];
    end;
    if ((length(scores) > 0) && (max(scores) >= 1));
        [cut_score, cut_to_make] = max(scores);
        live_segs = make_cut(live_segs, 1, cands(cut_to_make),pixels);
    else;
        done_segs = [done_segs; live_segs(1,:)];
        live_segs(1,:) = [];
    end;

    %if (((length(h_scores) > 0) && (max(h_scores) >= 1)) || ...
    %    ((length(v_scores) > 0) && (max(v_scores) >= 1)));
    %    if (max(v_scores) > max(h_scores));
    %        [cut_score,cut_to_make] = max(v_scores);
    %        live_segs = make_cut(live_segs, 1, cv(cut_to_make),pixels);
    %    else;    
    %        [cut_score,cut_to_make] = max(h_scores);
    %        live_segs = make_cut(live_segs, 1, ch(cut_to_make),pixels);
    %    end;
    %else;
    %    %fprintf('No cuts left. Removing.\n');
    %    done_segs = [done_segs; live_segs(1,:)];
    %    live_segs(1,:) = [];
    %end;
end;    

segs = done_segs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function segs = make_cut(segs, segnum, cand, pixels);
    oldseg = segs(segnum,:);
    %fprintf('Cutting [%i %i %i %i]\n',oldseg(1),oldseg(2),oldseg(3),oldseg(4));
    %fprintf('Making a %s cut ',cand.direction);
    segs(segnum,:) = [];
    if strcmp(cand.direction, 'horizontal');
        %Make a horizontal cut at cand.y;
        %fprintf(' at y=%i.\n', cand.y);
        newseg1 = oldseg;
        newseg1(4) = cand.y;
        newseg2 = oldseg;
        newseg2(2) = cand.y;
    elseif strcmp(cand.direction, 'vertical');
        %Make a vertical cut at cand.x
        %fprintf(' at x=%i.\n',cand.x);
        newseg1 = oldseg;
        newseg1(3) = cand.x;
        newseg2 = oldseg;
        newseg2(1) = cand.x;
    else;
        error('Unknown type of segmentation.');
        return;
    end;
    %fprintf('Into    [%i %i %i %i]\n',newseg1(1),newseg1(2),newseg1(3),newseg1(4));
    %fprintf('And     [%i %i %i %i]\n',newseg2(1),newseg2(2),newseg2(3),newseg2(4));
    newseg1 = seg_snap(pixels,newseg1,0);
    newseg2 = seg_snap(pixels,newseg2,0);

    if (rect_comes_before(newseg2, newseg1));
        segs = [newseg2; newseg1; segs];
    else;
        segs = [newseg1; newseg2; segs];
    end;



