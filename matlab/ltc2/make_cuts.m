function segs = make_cuts(cs, cut_cands, pixels);
%This function assumes cuts at the beginning and end of cs are
%not included in cut_cands.
if (length(cut_cands) == 0);
    segs = cs;
    return;
end;

cut_cands = pad_cut_cands(cut_cands,cs,pixels);

segs = [];
if strcmp(cut_cands(1).direction, 'horizontal');
    [junk,cut_order] = sort([cut_cands.y]);
    y = cut_cands(1).y;
    for i=2:length(cut_cands);
        next_cut = cut_cands(cut_order(i));
        seg = [cs(1), y, cs(3), next_cut.y];
        seg = seg_snap(pixels,seg,0);
        y = next_cut.y + 1;
        segs = [segs;seg];
    end;
else; %The cuts are vertical
    [junk,cut_order] = sort([cut_cands.x]);
    x = cut_cands(1).x;
    for i=2:length(cut_cands);
        next_cut = cut_cands(cut_order(i));
        seg = [x, cs(2), next_cut.x, cs(4)];
        seg = seg_snap(pixels,seg,0);
        x = next_cut.x + 1;
        segs = [segs;seg];
    end;
end;

segs = seg_snap(pixels,segs,0);


