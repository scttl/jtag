function samples = ltc2_create_samples_from_file(jt,pix);

%function samples = ltc2_create_samples_from_file(jt,pix);
%
% -pix are the result of imread(filepath).
%      -pix(y,x)


%------------------------------------------
%Prepare variables
if (nargin < 2);
    pixels = imread(jt.img_file);
else;
    pixels = pix;
end;

act_reg_map = zeros(size(pixels));
for i=1:size(jt.rects,1);
    act_reg_map(jt.rects(i,2):jt.rects(i,4), jt.rects(i,1):jt.rects(i,3))=i;
end;

seg_samples = [];

% segs = [Left Top Bottom Right
%         Left Top Bottom Right
%         ...]
start_seg = [1 1 size(pixels,2) size(pixels,1)];
start_seg = seg_snap(pixels, start_seg, 0);

live_segs = start_seg;

done_segs = [];

%------------------------------------------
%First, search for vert_full cuts (not implemented yet)
done_segs = live_segs;

%------------------------------------------
%Next, seach for hor in the results
[done_segs, seg_samps] = batch_cut(done_segs, pixels, act_reg_map, jt, 1, 1);
%fprintf('Adding hor seg_samps:\n');
%disp(seg_samps);
%fprintf('To seg_samples:\n');
%disp(seg_samples);
seg_samples = [seg_samps; seg_samples];

%-----------------------------------------
%Next, search for vert cuts in the results
[done_segs, seg_samps] = batch_cut(done_segs, pixels, act_reg_map, jt, 0, 0);
%fprintf('Adding seg_samps:\n');
%disp(seg_samps);
%fprintf('To seg_samples:\n');
%disp(seg_samples);
seg_samples = [seg_samps; seg_samples];

%-----------------------------------------
%Finally, look for hor part cuts.
[done_segs, seg_sampes] = batch_cut(done_segs, pixels, act_reg_map, jt, 1, 0);
seg_samples = [seg_samps; seg_samples];

samples = seg_samples;



%-----------------------------------------------------------
%--Subfunction Declarations
function [done_segs,seg_samples]=batch_cut(live_segs,pixels,act_reg_map,jt,h,f);

done_segs = [];
seg_samples = [];
while (~ isempty(live_segs));
    cs = live_segs(1,:);
    live_segs(1,:) = [];
    %fprintf('Operating on cs:\n');
    %disp(cs);
    cut_cands = ltc2_find_cand(pixels, cs, act_reg_map);
    if (length(cut_cands) > 0);
        cut_cands = cut_cands(find([cut_cands.horizontal] == h));
        %fprintf('Found %i cut cands.\n',length(cut_cands));
        seg_cands = get_seg_cands(cs, cut_cands, pixels,h);
        %fprintf('Which generated %i seg_cands.\n',length(seg_cands));
        seg_samps = ltc2_make_samples_from_cands(seg_cands,pixels,jt,h,f,cs);
        %fprintf('Creating %i seg_samps.\n', length(seg_samps));
        seg_samples = [seg_samples; seg_samps];
        %fprintf('For a total of %i seg_samples.\n\n\n',length(seg_samples));
        cut_cands = cut_cands(find([cut_cands.valid_cut]));
    end;
    if (length(cut_cands) > 0);
        %fprintf('Now making the %i valid cuts.\n',length(cut_cands));
        done_segs = [done_segs; make_cuts(cs,cut_cands,pixels)];
    elseif (f && ~h);
        %fprintf('Found no cut_cands.\n\n\n');
        done_segs = [done_segs; cs];
    end;
end;

%fprintf('done_segs:\n');
%disp(done_segs);



            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function seg_cands = get_seg_cands(cs, cut_cands, pixels, h);

%fprintf('Examining %i cut candidates, h=%i, cs=.\n', length(cut_cands),h);
%disp(cs);

seg_cands.rects = [];
seg_cands.segs_valid = [];

if isempty(cut_cands);
    return;
end;

if ((h) && (~all(strcmp({cut_cands.direction},'horizontal'))));
    fprintf('ERROR - there are %i vertical cuts in a horizontal batch.\n', ...
            length(find(1 - strcmp([cut_cands.direction],'horizontal'))));
elseif ((~h) && (~all(strcmp('vertical',{cut_cands.direction}))));
    fprintf('ERROR - there are %i horizontal cut in a vertical batch.\n', ...
            length(find(strcmp('vertical',{cut_cands.direction}))));
end;

cut_cands = pad_cut_cands(cut_cands,cs,pixels);
%fprintf('After padding, there are %i cut candidates.\n', length(cut_cands));

if h;
    [junk,cut_order] = sort([cut_cands.y]);
else;
    [junk,cut_order] = sort([cut_cands.x]);
end;


for i=1:length(cut_cands);
    c1 = cut_cands(cut_order(i));
    for j=i+1:length(cut_cands);
        c2 = cut_cands(cut_order(j));
        if (h); %horizontal
            seg_cand = [cs(1), min(c1.y,c2.y), cs(3), max(c1.y,c2.y)];
        else; %vertical
            seg_cand = [min(c1.x,c2.x), cs(2), max(c1.x,c2.x), cs(4)];
        end;
        %fprintf('Found a seg cand:\n');
        %disp(seg_cand);
        seg_cand = seg_snap(pixels,seg_cand,0);
        if (i>i || j<length(cut_cands)); %Don't re-add the original segment
            %fprintf('Adding cand:\n');
            %disp(seg_cand);
            seg_cands.rects = [seg_cands.rects; seg_cand];
            seg_valid = (c1.valid_cut && c2.valid_cut);
            if (seg_valid);
                for k=i+1:j-1;
                    if (cut_cands(cut_order(k)).valid_cut);
                        seg_valid = false;
                        break;
                    end;
                end;
            end;
            seg_cands.segs_valid = [seg_cands.segs_valid; seg_valid];
        end;
    end;
end;


