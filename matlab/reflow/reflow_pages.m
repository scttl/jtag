function pages = reflow_pages(blocks,p_width,p_height,m);

if (nargin <4);
    m.l = 100;
    m.r = 100;
    m.t = 100;
    m.b = 100;
end;

new_width = p_width - m.l - m.r;
new_height = p_height - m.t - m.b;

%fprintf('Start of reflow_pages, blocks:\n');
%disp(blocks);
blocks = undo_paging(blocks);

%fprintf('After undo_paging, blocks:\n');
%disp(blocks);
blocks = reflow_all_blocks(blocks,new_width);

%fprintf('After reflow_all_blocks, blocks:\n');
%disp(blocks);
pages = arrange_pages(blocks,new_width,new_height,m);



%----------------------------------------------
%Subfunctions

function pages = arrange_pages(blocks,new_width,new_height,m);

rs_v = 20;  %Vertical region spacing
rs_h = 30;

pages=[];
y = 1;
y_end = new_height;
page = [];
page.blocks = [];

doingbottom = false;
blocksforbottom = [];
while (length(blocks) > 0);
%Add blocks to page.blocks, until page is full, then add page to
%pages and start a new page.
    %Start by popping the first block off the list
    b = blocks(1);
    blocks(1)=[];
    
    %If the next block doesn't fit, end the page and start a new one.
    if ((y + rs_v + size(b.new_ink,1)) >= y_end);
        %Unless it is text, and at least one line of the text could
        %fit on this page, in which case split it and continue.
        if (is_text_region(char(b.cname)) && ...
            (y + rs_v + size(b.l_inks(1).ink,1) < y_end));
            b2 = b;
            b2.rect = [];
            b2.words = [];
            b2.original_ink = [];
            b2.l_inks = [];
            b2.new_ink = [];
            while ((y+rs_v+size(b.new_ink,1)) >= y_end);
                b2.l_inks = [b.l_inks(end);b2.l_inks];
                b.l_inks(end) = [];
                tink = [];
                for i=1:length(b.l_inks);
                    tink = [tink;b.l_inks(i).ink];
                end;
                b.new_ink = tink;
                tink = [];
                for i=1:length(b2.l_inks);
                    tink = [tink;b2.l_inks(i).ink];
                end;
                b2.new_ink = tink;
            end;
            %Now put b2 back in the list of blocks we still need to work on.
            blocks = [b2;blocks];
        else; %Start a new page.
            %If the last region on this page is a "keep with next" region,
            %then pull it off of this page before starting a new page.
            if (page.blocks(end).keepwithnext) && (length(page.blocks)>1);
                blocks = [page.blocks(end);blocks];
                page.blocks(end) = [];
            end;

            %Start a new page.
            %Unless we have blocks to add to the bottom, in which case
            %put b back in blocks for later, put these back in blocks,
            %and reset the y_end variable.
            %fprintf('Page done.  doingbottom=%i, len(b4b)=%i.\n', ...
            %        doingbottom, length(blocksforbottom));
            if (~doingbottom) && (length(blocksforbottom) > 0);
                fprintf('Ready to stick %i blocks on the bottom.\n', ...
                        length(blocksforbottom));
                blocks = [blocksforbottom;b;blocks];
                blocksforbottom = [];
                b = blocks(1);
                blocks(1) = [];
                y_end = new_height;
                doingbottom = true;
            else;
                if (length(blocksforbottom) > 0);
                    fprintf('ERROR - leftover blocksforbottom.\n');
                end;
                doingbottom = false;
                pages = [pages;page];
                page = [];
                page.blocks = [];
                y = 1;
            end;
        end;
    end;
    
    %See how many blocks we can fit side by side, without adding one that
    %will take us below the bottom of the page.
    blockstodrop=[];
    blockstodrop= [blockstodrop;b];
    x=size(b.new_ink,2);
    while ( (~b.takefullrow) && ...
            (length(blocks)>0) && ...
            (~blocks(1).takefullrow) && ...
            ((x+rs_h+size(blocks(1).new_ink,2)) < new_width) && ...
            ((y + rs_v + size(blocks(1).new_ink,1)) < y_end) );
        b=blocks(1);
        blocks(1) = [];
        blockstodrop=[blockstodrop;b];
        x = x + rs_h + size(b.new_ink,2);
    end;

    %Lay the blocks out, and change the rect for the blocks to be added
    %Begin by ordering the segments in the order left, center, right:
    for i=1:length(blockstodrop);
        for j=2:length(blockstodrop);
            b1 = blockstodrop(j-1);
            b2 = blockstodrop(j);
            if (b1.align_r && ~b2.align_r) || ...
               (b1.align_c && b2.align_l);
                %fprintf('Swapping l/r order of %s and %s.\n', ...
                %        char(b1.cname), char(b2.cname));
                blockstodrop(j-1) = b2;
                blockstodrop(j) = b1;
            end;
        end;
    end;

    sparex = new_width;
    for i=1:length(blockstodrop);
        sparex = sparex - size(blockstodrop(i).new_ink,2) -1;
        if (i>1);
            sparex = sparex - rs_h;
        end;
    end;
    
    x=1;
    x2 = new_width;
    newy=0;
    if (length(blockstodrop) == 1);
        b = blockstodrop(1);

        if (b.sticktobottom);
            y_top = y_end - size(b.new_ink,1) +1;
            y_end = y_end - size(b.new_ink,1) + 1 - rs_v;
            fprintf('Found %s, sticking to bottom, y_end=%i.\n', ...
                    char(b.cname), y_end);
            if (~doingbottom);
                fprintf('   ->Added it to blocksforbottom.\n');
                blocksforbottom = [b;blocksforbottom];
            else;
                fprintf('   ->Did not add it, as we are doing the bottom.\n');
            end;
        else;
            y_top = y;
        end;
        
        if (~b.sticktobottom) || (doingbottom);
            if (b.align_l);
                b.rect = [m.l,y_top+m.t,m.l+size(b.new_ink,2)-1, ...
                          y_top+m.t+size(b.new_ink,1)-1];
            elseif (b.align_r);
                b.rect = [x2+m.l-size(b.new_ink,2)+1, y_top+m.t, ...
                          x2+m.l, y_top+m.t+size(b.new_ink,1)-1];
            elseif (b.align_c);
                l_edge = floor((x+x2/2) - ((size(b.new_ink,2)-1)/2));
                b.rect=[m.l+l_edge, y_top+m.t, ...
                        m.l+l_edge+size(b.new_ink,2)-1, ...
                        y_top+m.t+size(b.new_ink,1)-1];
            else;
                fprintf('ERROR - a block is not aligned.\n');
            end;
            %fprintf('Assigned rect [%i %i %i %i]\n', b.rect(1), b.rect(2), ...
            %        b.rect(3), b.rect(4));
            page.blocks = [page.blocks;b];
            if (~b.sticktobottom);
                y = (b.rect(4)-m.t + rs_v);
            end;
        end;
    elseif (length(blockstodrop) == 2);
        b1 = blockstodrop(1);
        b2 = blockstodrop(2);
        %fprintf('Dropping %s and %s together on pg %i.\n', char(b1.cname), ...
        %        char(b2.cname), (length(pages)+1));
        if (b1.align_c && b2.align_r);
            b2.rect = [x2+m.l-size(b2.new_ink,2)+1, y+m.t, ...
                       x2+m.l,                      y+m.t+size(b2.new_ink,1)-1];
            x2 = b2.rect(1) - m.l;
            l_edge = floor((x+x2/2) - ((size(b1.new_ink,2)-1)/2));
            b1.rect = [m.l+l_edge, y+m.t, ...
                       m.l+l_edge+size(b1.new_ink,2)-1, ...
                       y+m.t+size(b1.new_ink,1)-1];
        elseif (b1.align_l && b2.align_c);
            b1.rect = [m.l, y+m.t, ...
                       m.l+size(b1.new_ink,2)-1, y+m.t+size(b1.new_ink,1)-1];
            x = size(b1.new_ink,2)-1;
            l_edge = floor((x+x2/2) - ((size(b1.new_ink,2)-1)/2));
            b2.rect = [m.l+l_edge, y+m.t, ...
                       m.l+l_edge+size(b2.new_ink,2)-1, ...
                       y+m.t+size(b2.new_ink,1)-1];
        else;
            b1.rect = [m.l, y+m.t, ...
                       m.l+size(b1.new_ink,2)-1, y+m.t+size(b1.new_ink,1)-1];
            b2.rect = [x2+m.l-size(b2.new_ink,2)+1, y+m.t, ...
                       x2+m.l,                      y+m.t+size(b2.new_ink,1)-1];
        end;
        page.blocks = [page.blocks;b1;b2];
        y = max(b1.rect(4),b2.rect(4)) - m.t + rs_v;
        %fprintf('Assigned rect1 [%i %i %i %i]\n', b1.rect(1), b1.rect(2), ...
        %        b1.rect(3), b1.rect(4));
        %fprintf('Assigned rect2 [%i %i %i %i]\n', b2.rect(1), b2.rect(2), ...
        %        b2.rect(3), b2.rect(4));
    else;
        newy = 0;
        x = 1;
        %fprintf('Dropping %i segments in one row.\n', length(blockstodrop));
        x_spc = rs_h + floor(sparex / (length(blockstodrop)-1));
        %fprintf('Computed x-spacing as %i.\n',x_spc);
        while (length(blockstodrop) > 0);
            b = blockstodrop(1);
            blockstodrop(1) = [];
            b.rect = [x+m.l,                       y+m.t, ...
                      x+m.l+(size(b.new_ink,2))-1, y+m.t+size(b.new_ink,1)-1];
            %fprintf('Assigned rect [%i %i %i %i]\n', b.rect(1), b.rect(2), ...
            %        b.rect(3), b.rect(4));
            x = x + size(b.new_ink,2) + x_spc;
        
            if (newy < (b.rect(4)-m.t + rs_v));
                newy = (b.rect(4)-m.t + rs_v);
            end;
        
            %Add the block to the page
            page.blocks = [page.blocks;b];
        end;
        y = newy;
    end;
    if (length(blocks) == 0) && ~doingbottom && (length(blocksforbottom) > 0);
        fprintf('For last page, ready to stick %i blocks on the bottom.\n', ...
                length(blocksforbottom));
        blocks = [blocksforbottom];
        blocksforbottom = [];
        y_end = new_height;
        doingbottom = true;
    end;
end;

old_pages=[pages;page];
pages=[];

for i=1:length(old_pages);
    %fprintf('Laying out pixels for page %i of %i.\n',i, length(old_pages));
    page = old_pages(i);
    new_ink = ones((new_height+m.t+m.b),(new_width+m.l+m.r));
    for j=1:length(page.blocks);
        b=page.blocks(j);
        %fprintf('    >Block %i, %s\n', j, char(b.cname));
        %fprintf('Assigning ink for %s: [%i, %i, %i, %i].\n', ...
        %        char(b.cname), b.rect(1), ...
        %        b.rect(2), b.rect(3), b.rect(4));
        new_ink(b.rect(2):b.rect(4),b.rect(1):b.rect(3)) = b.new_ink;
    end;
    page.pix = new_ink;
    pages = [pages;page];
end;



%----------------------------
function blocks = reflow_all_blocks(old_blocks,new_width);
    blocks = [];
    for i=1:length(old_blocks);
        b = reflow_region(old_blocks(i),new_width);
        blocks = [blocks;b];
    end;


