function blocks = get_page_blocks(jt, pix);
%
%function blocks = get_page_blocks(jt, pix);
%
% Extracts the "blocks" of ink from the regions defined in jt.
%
useslope = 30;
rorderscores = jt.rects(:,1) + (30 * jt.rects(:,2));
[junk,rorder] = sort(rorderscores,1,'ascend');

if (nargin < 2);
    pix = imread(jt.img_file);
end;

old_width = size(pix,2);
old_height = size(pix,1);

old_margins = [1 1 old_width old_height];
old_margins = seg_snap(pix,old_margins);

segs = jt.rects;

blocks = [];

j=0;
for i=rorder';
    j=j+1;
    clear block;
    block.rect = segs(i,:);
    block.cid = jt.class_id(i);
    block.cname = jt.class_name(jt.class_id(i));
    block.page_order = j;
    l=segs(i,1);
    t=segs(i,2);
    r=segs(i,3);
    b=segs(i,4);
    subpix = pix(t:b,l:r);
    if (is_text_region(block.cname));
        wordsegs = get_words(subpix);
        words = [];
        for k=1:size(wordsegs,1);
            word.rect = wordsegs(k,:);
            word.ink=subpix(wordsegs(k,2):wordsegs(k,4), ...
                            wordsegs(k,1):wordsegs(k,3));
            words = [words;word];
        end;
        word_inks = [];
        block.words = words;
        block.original_ink = subpix;
    else;
        block.words = [];
        block.original_ink = subpix;
    end;
    blocks = [blocks;block];
end;

blocks = find_formatting_info(blocks,pix);

