function res = reflow_article(article_name,newwidth,pageheight,margins);
%
% function res = reflow_article(article_name,newwidth);
%
% Reflows the article specified by article name.  Article_name should
% be the full path of the article, but should not include the page
% number indicator, nor the extension.  For example, if an article
% contains 4 pages:
%     /jtag/Journals/nips2001/AA01.aa.jtag
%     /jtag/Journals/nips2001/AA01.ab.jtag
%     /jtag/Journals/nips2001/AA01.ac.jtag
%     /jtag/Journals/nips2001/AA01.ad.jtag
% Then article_name should be "/jtag/Journals/nips2001/AA01".
%
% This function finds all the pages of that article using the pattern
% "<articlename>*.jtag".  It loads and displays the first page of the
% article.  To get at the article data structure, simply type:
%
% global article;
%
% in your workspace.  The article data structure will be returned, but
% the returned one will be a copy, not a reference to the original.  The
% original (global article) will be updated as you change pages, the 
% copy (res) will not.
%
% Once the article is loaded, use the left and right arrows to move to
% previous and next pages.
%
if (nargin < 4);
    margin_top = 100;
    margin_bottom = 100;
    margin_right = 50;
    margin_left = 50;
else;
    margin_top = margins.top;
    margin_bottom = margins.bottom;
    margin_right = margins.right;
    margin_left = margins.left;
end;

reg_spacing_v = 25;


global article;

if (strcmp(article_name(1:2), './') || strcmp(article_name(1:3), '../'));
    article_name = [pwd '/' article_name];
end;

tmp = dir([article_name, '.*.jtag']);

jt_paths = {tmp.name};

article.name = article_name;
article.fig_handle = -1;

article.page = {};

dot_idx = regexp(article_name, '/');
dirpath = article_name(1:dot_idx(length(dot_idx)));

if (length(jt_paths) == 0);
    fprintf('ERROR - no JTAG files found.');
end;

for i=1:length(jt_paths);
    fprintf('Loading %s%s\n',dirpath,jt_paths{i});
    article.page{i} = jt_load([dirpath,jt_paths{i}],false);
    jts(i) = article.page{i};
end;

allsegs = [];
for i=1:length(jts);
    fprintf('Reflowing file %i of %i.\n',i,length(jts));
    [junk,segs] = jt_reflow(jts(i),newwidth);
    allsegs = [allsegs,segs];
end;

if (nargin < 3);
    pix = imread(jts(i).img_file);
    pageheight = size(pix,1);
    pageheight = pageheight - (margin_top + margin_bottom);
end;


pages = [];
h = 1;
page.regs = [];
for i=1:length(allsegs);
    if (h + reg_spacing_v + seg_height(allsegs(i))) >= pageheight;
        pages = [pages,page];
        h = 1;
        page.regs = [];
    end;
    page.regs = [page.regs, allsegs(i)];
    h = h + reg_spacing_v + seg_height(allsegs(i));
end;
pages = [pages,page];

for i=1:length(pages);
    pink = ones(margin_top - reg_spacing_v + 1,newwidth);
    for j=1:length(pages(i).regs);
        pink = [pink; ones(reg_spacing_v,size(pink,2)); pages(i).regs(j).pix];
    end;
    pink=[pink; ones(margin_bottom,newwidth)];
    pink=[ones(size(pink,1),margin_left),pink,ones(size(pink,1),margin_right)];
    pink=[pink; ...
          ones((pageheight+margin_top+margin_bottom)-size(pink,1), ...
               size(pink,2))];
    imshow(pink);
    pages(i).ink = pink;
end;

res = pages;


%---------------------------------------------------
%Subfunctions
function h = seg_height(seg);
    if (size(seg) == [1,4]);
        h = seg(4) - seg(2) + 1;
    else;
        h = size(seg.pix,1);
    end;
