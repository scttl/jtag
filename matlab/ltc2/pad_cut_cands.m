function cut_cands = pad_cut_cands(cut_cands,cs,pixels);

cut_cands_original = cut_cands;

h = cut_cands(1).horizontal;

if (h);
    c1 = cut_cands(1);
    c1.y = max(cs(2)-1,1);
    c2 = cut_cands(end);
    c2.y = min(cs(4)+1,size(pixels,1));
    if (isfield(c1,'valid_cut'));
        c1.valid_cut = true;
        c2.valid_cut = true;
    end;
    cut_cands(2:end+1) = cut_cands;
%    fprintf('c1=\n');
%    disp(c1);
%    fprintf('cut_cands(1)=\n');
%    disp(cut_cands(1));
    cut_cands(1) = c1;
    cut_cands(end+1) = c2;
else; %vertical
    c1 = cut_cands(1);
    c1.x = max(cs(1)-1,1);
    c2 = cut_cands(end);
    c2.x = min(cs(3)+1,size(pixels,2));
    if (isfield(c1,'valid_cut'));
        c1.valid_cut = true;
        c2.valid_cut = true;
    end;
    cut_cands(2:end+1) = cut_cands;
    cut_cands(1) = c1;
    cut_cands(end+1) = c2;
end;
    

