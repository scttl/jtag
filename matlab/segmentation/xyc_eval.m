function scores = xyc_eval(pix, seg, candidates);

c_h = 24;
c_v = 80;

if isempty(candidates);
    scores = [];
end;

for cnum = 1:length(candidates);
    cand = candidates(cnum);
    if (strcmp(cand.direction, 'horizontal'));
        if (cand.val_len > c_h) && (cand.val_start ~= cand.seg_top) && ...
           (cand.val_end ~= cand.seg_bot);
            scores(cnum) = cand.val_len;
        else;
            scores(cnum) = 0;
        end;
    elseif (strcmp(cand.direction, 'vertical'));
        if (cand.val_len > c_v) && (cand.val_start ~= cand.seg_left) && ...
           (cand.val_end ~= cand.seg_right);
            scores(cnum) = cand.val_len;
        else;
            scores(cnum) = 0;
        end;
    else;
        fprintf('Unknown cut candidate type: %s\n',cand.direction);
        scores(cnum) = 0;
    end;
end;
