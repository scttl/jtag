function cands = get_cut_cands(pix, seg, h);

vlen_min_v = 7;
vlen_min_h = 5;

numcands = 0;

ws_thresh = 0.00;

left = seg(1);
top = seg(2);
right = seg(3);
bot = seg(4);

subpix = 1 - pix(top:bot, left:right);

proj_on_x = mean(subpix);
proj_on_y = mean(subpix')';

x_valleys = get_valleys(proj_on_x,0);
y_valleys = get_valleys(proj_on_y,0);

for i = 1:length(x_valleys);
    cand = [];
    valley = x_valleys(i);
    cand.direction = 'vertical';
    cand.horizontal = false;
    cand.y = 0;
    cand.x = left + round((valley.start + valley.end)/2) - 1;
    cand.val_len = valley.end - valley.start + 1;
    cand.val_start = valley.start + left - 1;
    cand.val_end = valley.end + left - 1;
    cand.val_area = cand.val_len * (right - left + 1);
    cand.seg_left = left;
    cand.seg_top = top;
    cand.seg_right = right;
    cand.seg_bot = bot;
    cand.ws_l = cand.val_start;
    cand.ws_r = cand.val_end;
    cand.ws_t = cand.seg_top;
    cand.ws_b = cand.seg_bot;
    if (cand.val_len >= vlen_min_v);
        numcands = numcands + 1;
        cands(numcands) = cand;
    end;
end;

for i = 1:length(y_valleys);
    cand = [];
    valley = y_valleys(i);
    cand.direction = 'horizontal';
    cand.horizontal = true;
    cand.y = top + round((valley.start + valley.end)/2) - 1;
    cand.x = 0;
    cand.val_len = valley.end - valley.start + 1;
    cand.val_start = valley.start + top - 1;
    cand.val_end = valley.end + top - 1;
    cand.val_area = cand.val_len * (bot - top + 1);
    cand.seg_left = left;
    cand.seg_top = top;
    cand.seg_right = right;
    cand.seg_bot = bot;
    cand.ws_l = cand.seg_left;
    cand.ws_r = cand.seg_right;
    cand.ws_t = cand.val_start;
    cand.ws_b = cand.val_end;
    if (cand.val_len >= vlen_min_h);
        numcands = numcands + 1;
        cands(numcands) = cand;
    end;
end;
    
if (numcands == 0);
    cands = [];
elseif (nargin > 2);
    cands = cands(find([cands.horizontal]==h));
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function valleys = get_valleys(proj,wst);

cval = [];
valopen = false;
v_num = 0;

for i=1:length(proj);
    if (proj(i) <= wst);
        %We're in a valley
        if (~valopen);
            %We're at the start of a new valley
            cval = [];
            cval.start = i;
            valopen = true;
            %fprintf('Starting new valley\n');
        else;
            %We're continuing an existing valley
            %fprintf('Continuing a valley\n');
        end;
        if (i == length(proj));
            %End of the projection - close the valley.
            %fprintf('Ended run inside a valley - closing valley\n');
            cval.end = i;
            v_num = v_num + 1;
            valleys(v_num) = cval;
            cval = [];
            valopen = false;
        end
    else;
        %We're not in a valley
        if (~valopen);
            %We're in the middle of a non-valley stretch.
            %fprintf('Middle of a non-valley stretch\n');
        else;
            %We're just past the end of a valley.
            %fprintf('Closing a valley\n');
            cval.end = i-1;
            v_num = v_num + 1;
            valleys(v_num) = cval;
            cval = [];
            valopen = false;
        end;
    end;
end;

if (v_num == 0);
    valleys = [];
end;

