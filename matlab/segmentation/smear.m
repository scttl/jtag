function segs = smear(pixels, x_smear, y_smear, drawit);
%
%function segs = smear(pix, x_smear, y_smear);
%
% pix(top:bot,left:right);
%
bg = 1;
pix = bg - pixels;
pix = (pix > 0.5);


if (nargin >= 2);
    xsm = x_smear;
else;
    xsm = 40;
end;
if (nargin >= 3);
    ysm = y_smear;
else
    ysm = 20;
end;

px = pix;
for i=2:(xsm+1);
    p_add = [pix(:,i:end), zeros(size(pix,1),i-1)];
    px = px + p_add;
    p_add = [zeros(size(pix,1),i-1), pix(:,1:end-(i-1))];
    px = px + p_add;
end;
px = (px > 0);

py = pix;
for i=2:(ysm+1);
    p_add = [pix(i:end,:); zeros(i-1,size(pix,2))];
    py = py + p_add;
    p_add = [zeros(i-1,size(pix,2)); pix(1:end-(i-1),:)];
    py = py + p_add;
end;
py = (py > 0);

pix = ((px + py) < 1); %Smearing algorithm.
pix = 1 - pix;



[markmap, nummarks] = bwlabel(pix,8);

segs = [];

for i=1:nummarks;
    [ink_y,ink_x] = find(markmap == i);
    top = min(ink_y);
    bot = max(ink_y);
    left = min(ink_x);
    right = max(ink_x);
    newseg = [left top right bot];
    segs = [segs; left top right bot];
end;

segs = seg_snap(pixels,segs,0);

if (nargin >= 4) && (drawit);
    seg_plot(pixels,segs);
end;
