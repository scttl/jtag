function lines = get_text_lines(pix, jt);

se = strel('line',3,90);
p2 = imdilate(pix, se);
lines = smear(p2, 20, 0, 0);
lines=[lines(:,1),max(lines(:,2)-1,1),lines(:,3), ...
       min(lines(:,4)+1,size(pix,1))];

lines = kill_overlapping_segs(pix, lines);

[junk,lineorder] = sort(lines(:,2));

lines = lines(lineorder,:);


%Subfunctions
%------------------------------
function segs_out = kill_overlapping_segs(pix,segs);


sizes = (segs(:,3) - segs(:,1) + 1) .* (segs(:,4) - segs(:,2) + 2);

[junk, sizeorder] = sort(sizes,1,'descend');
    
seg_map = zeros(size(pix));
segs_out = [];
for i=1:length(sizeorder);
    seg = segs(sizeorder(i),:);
    segs_tmp(i).empty = true;
    segs_tmp(i).seg = [];
    sm2 = seg_map;
    sm2(seg(2):seg(4),seg(1):seg(3)) = sm2(seg(2):seg(4),seg(1):seg(3)) + 1;
    if (max(max(sm2)) == 1);
        seg_map = sm2;
        segs_out = [segs_out; seg];
    else;
        %fprintf('Found overlapping regions.  Deleting smaller one.\n');
    end;
end;



