function block = reflow_region(block,new_width);

if (~is_text_region(block.cname));
    block = resize_block(block,new_width);
else;
    block = reflow_block(block,new_width);
end;


%----------------------------------------------------
%Subfunctions

function block = resize_block(block,new_width);
    r = block.rect;
    block.l_inks = [];
    if ((r(3)-r(1)+1) >= new_width);
        resizefactor = (new_width-1) / (r(3)-r(1)+1);
        oldpix = block.original_ink;
        p = imresize(oldpix,resizefactor);
        block.new_ink = (p > 0);
    else;
        block.new_ink = (block.original_ink > 0);
    end;


%--------------------------------------------------

function block = reflow_block(block,new_width);

full_justify = block.align_full;

interline_space = 2;
min_word_spacing = 8;

word_inks = block.words;

left = 1;
curline.words = [];
all_lines = [];
%fprintf('Rearranging the %i words.\n',length(word_inks));
for j=1:length(word_inks);
    wink = word_inks(j);
    if ((left + size(wink.ink,2)) >= new_width);
        curline.sparewidth = new_width - (left - min_word_spacing);
        all_lines = [all_lines, curline];
        left = 1;
        curline.words = [];
    end;
    wink.left = left;
    curline.words = [curline.words, wink];
    left = left + size(wink.ink,2) + min_word_spacing;
end;
curline.sparewidth = max(new_width-(left-min_word_spacing), 5);
curline.sparewidth = 0;
all_lines = [all_lines, curline];

links = [];
l_inks = [];
%fprintf('Distributed the words into %i lines.\n',length(all_lines));
for j=1:length(all_lines);
    curline = all_lines(j);
    maxheight = 0;
    if (length(curline.words) < 1);
        fprintf('Error - assigned an empty line.\n');
    end;
    for k=1:length(curline.words);
        wink = curline.words(k);
        maxheight = max(size(wink.ink,1),maxheight);
    end;
    link = ones(maxheight,new_width);
    if (length(curline.words) > 1);
        extra_word_space=floor(curline.sparewidth / ...
                               (length(curline.words)-1));
        sparepixels = curline.sparewidth - (extra_word_space * ...
                                            (length(curline.words)-1));
    else;
        extra_word_space=0;
        sparepixels = 0;
    end;
    for k=1:length(curline.words);
        wink = curline.words(k);
        if (full_justify);
            l = wink.left + (extra_word_space * (k-1)) + ...
                min((k-1),sparepixels);
            r = l + size(wink.ink,2) -1;
            
        else;
            l = wink.left;
            r = l + size(wink.ink,2) -1;
        end;
        b = maxheight;
        t = maxheight - size(wink.ink,1) + 1;
        link(t:b,l:r) = wink.ink;
    end;
    
    %Add some whitespace at the bottom of the line.
    link = [link;ones(interline_space,size(link,2))];
    
    if (size(link,2) > new_width);
        fprintf('ERROR - region is too wide.\n');
        imshow(link);
    end;
    link = [link, ones(size(link,1), (new_width - size(link,2)))];
    if (size(link,2) ~= size(links,2)) && (size(links,2) > 0);
        fprintf('ERROR - width of link=%i, width of links=%i\n', ...
                size(link,2), size(links,2));
    end;
    tmp.ink = link;
    l_inks = [l_inks;tmp];
    links = [links;link];
end;

block.l_inks = l_inks;
block.new_ink = links;


