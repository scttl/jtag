function [samples,feat_names] = ltc3_create_samples_from_file(jt,pix);

%function samples = ltc3_create_samples_from_file(jt,pix);
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

cut_samples = [];

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
[done_segs, cut_samps] = batch_cut(done_segs, pixels, act_reg_map, jt, 1, 1);
%fprintf('Adding hor seg_samps:\n');
%disp(seg_samps);
%fprintf('To seg_samples:\n');
%disp(seg_samples);
cut_samples = [cut_samples;cut_samps];

%-----------------------------------------
%Next, search for vert cuts in the results
[done_segs, cut_samps] = batch_cut(done_segs, pixels, act_reg_map, jt, 0, 0);
%fprintf('Adding seg_samps:\n');
%disp(seg_samps);
%fprintf('To seg_samples:\n');
%disp(seg_samples);
cut_samples = [cut_samples;cut_samps];

%-----------------------------------------
%Finally, look for hor part cuts.
[done_segs, cut_sampes] = batch_cut(done_segs, pixels, act_reg_map, jt, 1, 0);
cut_samples = [cut_samples;cut_samps];

samples = cut_samples;



%-----------------------------------------------------------
%--Subfunction Declarations
function [done_segs,cut_samples]=batch_cut(live_segs,pixels,act_reg_map,jt,h,f);

done_segs = [];
cut_samples = [];
while (~ isempty(live_segs));
    cs = live_segs(1,:);
    live_segs(1,:) = [];
    %fprintf('Operating on cs:\n');
    %disp(cs);
    cut_cands = ltc3_find_cand(pixels, cs, act_reg_map);
    if (length(cut_cands) > 0);
        cut_cands = cut_cands(find([cut_cands.horizontal] == h));
        %fprintf('Found %i cut cands.\n',length(cut_cands));
        cut_samps = ltc3_make_samples_from_cands(cut_cands,pixels,jt,h,f,cs);
        %fprintf('Creating %i seg_samps.\n', length(seg_samps));
        cut_samples = [cut_samples; cut_samps];
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

