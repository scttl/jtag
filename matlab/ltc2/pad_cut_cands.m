function cut_cands = pad_cut_cands(cut_cands,cs,pixels);

h = cut_cands(1).horizontal;

if (h);
    c1 = cut_cands(1);
    c1.valid_cut = true;
    c1.y = max(cs(2)-1,1);
    c2 = cut_cands(end);
    c2.valid_cut = true;
    c2.y = min(cs(4)+1,size(pixels,1));
    cut_cands = [c1,cut_cands,c2];
else; %vertical
    c1 = cut_cands(1);
    c1.valid_cut = true;
    c1.x = max(cs(1)-1,1);
    c2 = cut_cands(end);
    c2.valid_cut = true;
    c2.x = min(cs(3)+1,size(pixels,2));
    cut_cands = [c1,cut_cands,c2];
end;
    

