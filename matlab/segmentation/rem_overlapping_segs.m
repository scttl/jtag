function segs_out = rem_overlapping_segs(pix,segs);
%
%function segs_out = rem_overlapping_segs(pix,segs);
%

fixed_any = true;
while (fixed_any);
fixed_any = false;
segs_done = [];
while size(segs,1) > 0;
    s1 = segs(1,:);
    segs(1,:) = [];
    j = 1;
    while (j < size(segs,1));
        s2 = segs(j,:);
        if (((s1(2)<=s2(2)) && (s1(4)>=s2(2))) || ...  %They overlap vertically
            ((s2(2)<=s1(2)) && (s2(4)>=s1(2)))) ...
           && ...
           (((s1(1)<=s2(1)) && (s1(3)>=s2(1))) || ...  %And horizontally
            ((s2(1)<=s1(1)) && (s2(3)>=s1(1))));
            s1 = [min(s1(1),s2(1)), min(s1(2),s2(2)), ...
                  max(s1(3),s2(3)), max(s1(4),s2(4))];
            segs(j,:) = [];
            fixed_any = true;
        else;
            j = j+1;
        end;
    end;
    segs_done = [segs_done;s1];
end;
segs = segs_done;
end;


segs_out = segs_done;
return;


sizes = (segs(:,3) - segs(:,1) + 1) .* (segs(:,4) - segs(:,2) + 2);
[junk, sizeorder] = sort(sizes,1,'descend');
    
%Merge overlapping segments
seg_map = zeros(size(pix));
segs_that_overlap = [];
for i=1:length(sizeorder);
    seg = segs(sizeorder(i),:);
    segs_tmp(i).empty = true;
    segs_tmp(i).seg = [];
    sm2 = zeros(size(seg_map));
    sm2 = sm2 + seg_map;
    sm2(seg(2):seg(4),seg(1):seg(3)) = sm2(seg(2):seg(4),seg(1):seg(3)) + 1;
    if (max(max(sm2)) == 1);
        seg_map = sm2;
    else;
        %fprintf('Found overlapping regions.  Deleting smaller one.\n');
        seg_map = (sm2 > 0);
        segs_that_overlap = [segs_that_overlap,i];
    end;
end;

fprintf('Found %i overlapping regions\n',length(segs_that_overlap));

for i=1:size(segs,1);
    s1 = segs(i,:);
    for j=1:length(segs_that_overlap);
        s2 = segs(segs_that_overlap(j),:);
        if (((s1(2)<=s2(2)) && (s1(4)>=s2(2))) || ...  %They overlap vertically
            ((s2(2)<=s1(2)) && (s2(4)>=s1(2))));
            fprintf('V-overlap:[%i %i %i %i], [%i %i %i %i]\n', ...
                    s1(1),s1(2),s1(3),s1(4),s2(1),s2(2),s2(3),s2(4));
        if (((s1(1)<=s2(1)) && (s1(3)>=s2(1))) || ...  %They overlap vertically
            ((s2(1)<=s1(1)) && (s2(3)>=s1(1))));
            fprintf('H-overlap:[%i %i %i %i], [%i %i %i %i]\n', ...
                    s1(1),s1(2),s1(3),s1(4),s2(1),s2(2),s2(3),s2(4));
        end; end;

        if (((s1(2)<=s2(2)) && (s1(4)>=s2(2))) || ...  %They overlap vertically
            ((s2(2)<=s1(2)) && (s2(4)>=s1(2)))) ...
           && ...
           (((s1(1)<=s2(1)) && (s1(3)>=s2(1))) || ...  %And horizontally
            ((s2(1)<=s1(1)) && (s2(3)>=s1(1))));
            fprintf('Found that [%i %i %i %i] and [%i %i %i %i] overlap\n', ...
                    s1(1),s1(2),s1(3),s1(4),s2(1),s2(2),s2(3),s2(4));
            s1 = [min(s1(1),s2(1)), min(s1(2),s2(2)), ...
                  max(s1(3),s2(3)), max(s1(4),s2(4))];
        end;
    end;
    segs(i,:) = s1;
end;

useslope = 30;
[junk,segorder] = sort((useslope * segs(:,2)) + segs(:,1));
segs = segs(segorder,:);

i = 1;
while (i < size(segs,1));
    s1 = segs(i,:);
    s2 = segs(i+1,:);
    if (all(s1 == s2));
        segs(i) = [];
    else;
        i = i+1;
    end;
end;
segs_out = segs;
