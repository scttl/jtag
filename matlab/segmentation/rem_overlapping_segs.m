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
    while (j <= size(segs,1));
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

