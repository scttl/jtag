function res = load_article(article_name);
%
% function res = load_article(article_name);
%
% Loads the article specified by article name.  Article_name should
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

tmp = dir([article_name, '.*.jtag']);

jt_files = {tmp.name};

article.name = article_name;
article.fig_handle = -1;

article.page = {};

dot_idx = regexp(article_name, '/');
dirpath = article_name(1:dot_idx(length(dot_idx)));

for i=1:length(jt_files);
    fprintf('Loading %s%s\n',dirpath,jt_files{i});
    article.page{i} = jt_load([dirpath,jt_files{i}],false);
end;

cg = colourguide;

%f = figure('KeyPressFcn',@keyPressed);
%article.fig_handle = f;
article.curpage = 1;
page(1);
%jt_plot(article.page{1},f);

res = article;


function keyPressed(obj,eventdata);
    lastChar = get(obj,'CurrentCharacter');
    if ((lastChar == char(28)) || (lastChar == char(30)) || ...
        (lastChar == 'p') || (lastChar == 'P'));
        pp;
    elseif ((lastChar == char(29)) || (lastChar == char(31)) || ...
            (lastChar == 'n') || (lastChar == 'N'));
        np;
    end;
    


