function blocks = get_article_blocks(article_name);
%
% function res = get_article_blocks(article_name,newwidth);
%
% Gets all the "blocks" from an article.  Article_name should
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
global article;

if (strcmp(article_name(1:2), './') || strcmp(article_name(1:3), '../'));
    article_name = [pwd '/' article_name];
end;

tmp = dir([article_name, '.*.jtag']);
tmp = dir([article_name, '*.jtag']);

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
    article.page{i} = jt_load([dirpath,jt_paths{i}],false);
    jts(i) = article.page{i};
end;

blocks = [];

for i=1:length(jts);
    fprintf('Processing page %i of %i: %s\n',i,length(jts),jts(i).jtag_file);
    b = get_page_blocks(jts(i));
    for j=1:length(b);
        b(j).page_num = i;
        b(j).num_pages = length(jts);
        b(j).blocks_in_page = length(b);
    end;
    blocks = [blocks;b];
end;

