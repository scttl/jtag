function newsegs = reflow_region(pix, new_width, segs);

full_justify = true;
interline_space = 2;
min_word_spacing = 8;

old_width = size(pix,2);

if (nargin < 3);
    segs = [1,1,size(pix,2),size(pix,1)];
end;

for i=1:size(segs,1);
    word_inks = [];
    l=segs(i,1);
    t=segs(i,2);
    r=segs(i,3);
    b=segs(i,4);
    subpix = pix(t:b,l:r);
    word_segs = get_words(subpix);
    %seg_plot(subpix, word_segs);
    clear words;
    for j=1:size(word_segs,1);
        wl = word_segs(j,1);
        wt = word_segs(j,2);
        wr = word_segs(j,3);
        wb = word_segs(j,4);
        
        words(j).ink = subpix(wt:wb,wl:wr);
    end;
    word_inks = [word_inks,words];
    subpix = ones(size(subpix));

    left = 1;
    curline.words = [];
    all_lines = [];
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
        if (~isempty(links));
            links = [links;ones(interline_space,size(links,2))];
        end;
        if (size(link,2) > new_width);
            fprintf('ERROR - region is too wide.\n');
            imshow(link);
        end;
        link = [link, ones(size(link,1), (new_width - size(link,2)))];
        if (size(link,2) ~= size(links,2)) && (size(links,2) > 0);
            fprintf('ERROR - width of link=%i, width of links=%i\n', ...
                    size(link,2), size(links,2));
        end;
        links = [links;link];
    end;
    newsegs(i).ink = links;
end;

if (nargin < 3);
    seg_plot(newsegs(1).ink,[1 2 3 4]);
end;
