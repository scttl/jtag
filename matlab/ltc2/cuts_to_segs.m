function [seg_cands,cut_cands] = cuts_to_segs(cs,cut_cands,pixels,h,td);

if (nargin < 5);
    td = true;  %td is a boolean indicating whether we are building training
                %data.
end;

seg_cands.rects = [];
seg_cands.segs_valid = [];
seg_cands.cut_before = [];
seg_cands.cut_after = [];

if isempty(cut_cands);
    return;
end;

if ((h) && (~all(strcmp({cut_cands.direction},'horizontal'))));
    fprintf('ERROR - there are %i vertical cuts in a horizontal batch.\n', ...
            length(find(1 - strcmp({cut_cands.direction},'horizontal'))));
elseif ((~h) && (~all(strcmp('vertical',{cut_cands.direction}))));
    fprintf('ERROR - there are %i horizontal cut in a vertical batch.\n', ...
            length(find(1-strcmp('vertical',{cut_cands.direction}))));
end;

cut_cands = pad_cut_cands(cut_cands,cs,pixels);
%fprintf('After padding, there are %i cut candidates.\n', length(cut_cands));

if h;
    [junk,cut_order] = sort([cut_cands.y]);
else;
    [junk,cut_order] = sort([cut_cands.x]);
end;

cut_cands = cut_cands(cut_order);

for i=1:length(cut_cands);
    cut_cands(i).index = i;
    c1 = cut_cands(i);
    for j=i+1:length(cut_cands);
        c2 = cut_cands(j);
        if (h); %horizontal
            seg_cand = [cs(1), min(c1.y,c2.y), cs(3), max(c1.y,c2.y)];
        else; %vertical
            seg_cand = [min(c1.x,c2.x), cs(2), max(c1.x,c2.x), cs(4)];
        end;
        %fprintf('Found a seg cand:\n');
        %disp(seg_cand);
        seg_cand = seg_snap(pixels,seg_cand,0);
        if (~td) || (i>1 || j<length(cut_cands)); %If we're building training
                                               %data, then don't re-add the 
                                               %original segment
            %fprintf('Adding cand:\n');
            %disp(seg_cand);
            seg_cands.rects = [seg_cands.rects; seg_cand];
            seg_cands.cut_before = [seg_cands.cut_before; i];
            seg_cands.cut_after = [seg_cands.cut_after; j];
            if td && (isfield(c1,'valid_cut'));
                %fprintf('Checking if segment should be valid.\n');
                seg_valid = (c1.valid_cut && c2.valid_cut);
                if (seg_valid);
                    if (i+1 <= j-1);
                        vc=[cut_cands(i+1:j-1).valid_cut];
                        if (any(vc));
                            seg_valid = false;
                        end;
                    end;
                end;
            else;
                seg_valid = true;
            end;
            seg_cands.segs_valid = [seg_cands.segs_valid; seg_valid];
        end;
    end;
end;


