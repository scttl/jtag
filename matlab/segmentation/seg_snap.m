function segs = seg_snap(pix, segs, white_space_threshold);
%
%function segs = seg_snap(pix, segs, white_space_threshold);
%
% Snaps the segments segs, based on the pixels pix.
%

%
%if (islogical(segs));
%    s = zeros(size(segs));
%    s = s + segs;
%    segs = s;
%    clear s;
%end;
%
%if (islogical(pix));
%    p = zeros(size(pix));
%    p = p + pix;
%    pix = p;
%    clear p;
%end;

wst = 0;
if (nargin >= 3);
    wst = white_space_threshold;
end;

for i=1:size(segs,1);
    seg = segs(i,:);
    seg = snap_simple(pix,seg,0);
    segs(i,:) = seg;
end;


function seg = snap_simple(pix, seg, white_space_threshold);


wst = 0;
if (nargin >= 3);
    wst = white_space_threshold;
end;

left = seg(1);
top = seg(2);
right = seg(3);
bot = seg(4);

%fprintf('Snapping [%i %i %i %i], with wst=%i\n',left,top,right,bot,wst);

subpix = pix(top:bot, left:right);

if (max(max(1 - subpix)) <= wst);
    %Empty segment: snap to the single pixel at the center.
    seg = [floor((left+right)/2), floor((top+bot)/2), ...
           floor((left+right)/2), floor((top+bot)/2)];
    return;
end;

if (size(subpix,2) > 1);
    %If there is any horizontal snapping that could be done
    if (size(subpix,1) > 1);
        prj_on_x = mean(1 - subpix);
    else;
        prj_on_x = 1 - subpix;
    end;

    ink_x = find(prj_on_x > wst);
    if (length(ink_x) > 0);
        right = ink_x(end) + left - 1;
        left = ink_x(1) + left - 1;
    end;
end;

if (size(subpix,1) >1);
    %If there is any vertical snapping that could be done
    if (size(subpix,2) > 1);
        prj_on_y = mean(1 - subpix');
    else;
        prj_on_y = 1 - subpix';
    end;
    ink_y = find(prj_on_y > wst);
    if (length(ink_y) > 0);
        %fprintf('y-ink starts %i and ends %i from the top: %i\n', ink_y(1), ...
        %        ink_y(end), top);
        bot = ink_y(end) + top - 1;
        top = ink_y(1) + top - 1;
        %fprintf('      so top=%i, bot=%i\n',top, bot);
    else;
        %fprintf('Attempting to snap a vertically empty rectangle.  Returning original.\n');
    end;
end;

%fprintf('To       [%i %i %i %i]\n',left,top,right,bot);

seg = [left top right bot];
