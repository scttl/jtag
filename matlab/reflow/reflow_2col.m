function [pages,jts] = reflow_2col(article_name,savepath);

pages = get_2col_pages(article_name);

if (nargin >= 2);
    jts = pages_to_jtag(pages, savepath, true, true);
else;
    jts = [];
end;


function pages = get_2col_pages(article_name);

marg_r = 70;
marg_l = 70;

col_margins.l = 30;
col_margins.r = 30;
col_margins.t = 100;
col_margins.b = 100;

[pwidth,pheight] = get_page_size(article_name);

colwidth = floor((pwidth - marg_r - marg_l)/2);
colheight = pheight;

blocks = get_article_blocks(article_name);
%fprintf('In reflow_2col, blocks:\n');
%disp(blocks);
columns = reflow_pages(blocks,colwidth,colheight,col_margins);

pages = [];
pnew = [];
for i=1:2:length(columns);
    newpix = ones(pheight,pwidth);
    c = columns(i);
    newpix(1:colheight,marg_l:marg_l+colwidth-1) = c.pix;
    page.pix = newpix;
    page.blocks = c.blocks;
    if (i < length(columns));
        c = columns(i+1);
        %fprintf('l:%i, r:%i, w:%i\n', (pwidth-marg_r-colwidth+1), ...
        %        pwidth-marg_r, size(c.pix,2));
        newpix(1:colheight, ...
               pwidth-marg_r-colwidth+1:pwidth-marg_r) = c.pix;
        for j=1:length(c.blocks);
            c.blocks(j).rect(1) = c.blocks(j).rect(1)+colwidth;
            c.blocks(j).rect(3) = c.blocks(j).rect(3)+colwidth;
        end;
        page.pix = newpix;
        page.blocks = [page.blocks;c.blocks];
    end;
    for j=1:length(page.blocks);
        page.blocks(j).rect(1) = page.blocks(j).rect(1)+marg_l-1;
        page.blocks(j).rect(3) = page.blocks(j).rect(3)+marg_l-1;
    end;
    pages = [pages;page];
end;

%----------------------------------------------------
%Subfunctions

function [w,h] = get_page_size(article_name);

if (strcmp(article_name(1:2), './') || strcmp(article_name(1:3), '../'));
    article_name = [pwd '/' article_name];
end;

dot_idx = regexp(article_name, '/');
dirpath = article_name(1:dot_idx(length(dot_idx)));

tmp = dir([article_name, '.*.jtag']);
tmp = dir([article_name, '*.jtag']);

jt_paths = {tmp.name};
%fprintf('Loading "%s"\n', [char(dirpath),char(jt_paths(1))]);
jt = jt_load([char(dirpath),char(jt_paths(1))],false);
pix = imread(jt.img_file);
h = size(pix,1);
w = size(pix,2);

