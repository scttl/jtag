function segs = best_cuts(pixels, get_cand_fn, eval_cand_fn, pre_fn, post_fn);

%function segs = best_cuts(pixels, get_cand_fn, eval_cand_fn, pre_fn, post_fn);
%
% -pixels are the result of imread(filepath).
% -get_cand_fn is a string indicating the function to get candidates.
%    -all candidates should have at least the following fields:
%        -candidate.direction = ['horizontal' or 'vertical']
%        -candidate.x = [number if direction is 'vertical']
%        -candidate.y = [number if direction is 'horizontal']
% -eval_cand_fn is a string indicating the function to evaluate a list
%  of candidates, as created by get_cand_fn.


%pixels(y,x)

if ((nargin >= 4) && ~strcmp(pre_fn, ''));
    evalstr = [pre_fn '(pixels)'];
    pixels = eval(evalstr);
end;

% segs = [Left Top Bottom Right
%         Left Top Bottom Right
%         ...]
start_seg = [1 1 size(pixels,2) size(pixels,1)];
start_seg = seg_snap(pixels, start_seg, 0);

live_segs = start_seg;

done_segs = [];

its = 0;
while (~ isempty(live_segs));
    its = its + 1;
    fprintf('In iteration %i, lives_segs=\n',its);
    disp(live_segs);
    cs = live_segs(1,:);
    fprintf('Checking [%i %i %i %i] for cuts.\n',cs(1),cs(2),cs(3),cs(4));
    evalstr = [get_cand_fn '(pixels, live_segs(1,:));'];
    candidates = eval(evalstr);
    evalstr = [eval_cand_fn '(pixels, live_segs(1,:), candidates);'];
    scores = eval(evalstr);
    if ((length(scores) > 0) && (max(scores) >= 1));
        [cut_score,cut_to_make] = max(scores);
        live_segs = make_cut(live_segs, 1, candidates(cut_to_make),pixels);
    else;
        fprintf('No cuts left. Removing.\n');
        done_segs = [done_segs; live_segs(1,:)];
        live_segs(1,:) = [];
    end;
end;    

if ((nargin == 5) && ~strcmp(post_fn, ''));
    evalstr = [post_fn '(pixels, done_segs)'];
    done_segs = eval(evalstr);
end;

segs = done_segs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function segs = make_cut(segs, segnum, cand, pixels);
    oldseg = segs(segnum,:);
    fprintf('Cutting [%i %i %i %i]\n',oldseg(1),oldseg(2),oldseg(3),oldseg(4));
    fprintf('Making a %s cut ',cand.direction);
    segs(segnum,:) = [];
    if strcmp(cand.direction, 'horizontal');
        %Make a horizontal cut at cand.y;
        fprintf(' at y=%i.\n', cand.y);
        newseg1 = oldseg;
        newseg1(4) = cand.y;
        newseg2 = oldseg;
        newseg2(2) = cand.y;
    elseif strcmp(cand.direction, 'vertical');
        %Make a vertical cut at cand.x
        fprintf(' at x=%i.\n',cand.x);
        newseg1 = oldseg;
        newseg1(3) = cand.x;
        newseg2 = oldseg;
        newseg2(1) = cand.x;
    else;
        error('Unknown type of segmentation.');
        return;
    end;
    fprintf('Into    [%i %i %i %i]\n',newseg1(1),newseg1(2),newseg1(3),newseg1(4));
    fprintf('And     [%i %i %i %i]\n',newseg2(1),newseg2(2),newseg2(3),newseg2(4));
    newseg1 = seg_snap(pixels,newseg1,0);
    newseg2 = seg_snap(pixels,newseg2,0);

    if (rect_comes_before(newseg2, newseg1));
        segs = [newseg2; newseg1; segs];
    else;
        segs = [newseg1; newseg2; segs];
    end;



    

