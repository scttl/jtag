function lines = get_text_lines(pix, jt);

se = strel('line',3,90);
p2 = imdilate(pix, se);
lines = smear(p2, 20, 0, 0);
lines=[lines(:,1),max(lines(:,2)-1,1),lines(:,3), ...
       min(lines(:,4)+1,size(pix,1))];

lines = kill_overlapping_segs(pix, lines);

useslope = 10;
sortscores = (useslope * lines(:,2)) + lines(:,1);

[junk,lineorder] = sort(sortscores);

lines = lines(lineorder,:);


%Subfunctions
%------------------------------
function segs_out = kill_overlapping_segs(pix,segs);


sizes = (segs(:,3) - segs(:,1) + 1) .* (segs(:,4) - segs(:,2) + 2);
[junk, sizeorder] = sort(sizes,1,'descend');
    
%Begin by deleting partially covered regions.  Usually, this means that
%the smaller region is something like the dot on an i.
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

%Next, take any regions in which just the vertical projections overlap,
%and merge them.  These are usually parts of a line that have been
%separated by a lot of whitespace.
segs = segs_out;
segs_out = [];
if (size(segs,2) ~= 4);
    fprintf('ERROR - segs is wrong.\n');
    disp(segs);
end;
while(size(segs,1) >= 2);
    [junk,sorder] = sort(segs(:,2));
    s1 = segs(sorder(1),:);
    s2 = segs(sorder(2),:);
    segs(sorder([1,2]),:) = [];
    if (((s1(2)<s2(2)) && (s1(4)>s2(2))) || ...
        ((s2(2)<s1(2)) && (s2(4)>s1(2))));
        snew=[min(s1(1),s2(1)),min(s1(2),s2(2)), ...
              max(s1(3),s2(3)),max(s1(4),s2(4))];
        segs_out = [segs_out;snew];
    else;
        segs_out = [segs_out;s1];
        segs = [s2;segs];
    end;
end;
segs_out = [segs_out;segs];
