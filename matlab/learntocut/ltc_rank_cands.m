function scores = ltc_rank_cands(pix, seg, candidates);

if isempty(candidates);
    scores = [];
end;

for cnum = 1:length(candidates);
    cand = candidates(cnum);
    if (cand.valid_cut);
        cscore = (30 * cand.ws_t) + cand.ws_l;
        if (cand.fullpage);
            cscore = cscore + 100000;
            if (strcmp(cand.direction, 'vertical'));
                cscore = cscore + 100000;
            end;
        end;
    else;
        cscore = 0;
    end;
    scores(cnum) = cscore;
    
end;
