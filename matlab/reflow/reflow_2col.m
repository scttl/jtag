function res = reflow_2col(article_name);

final_marg_r = 30;
final_marg_l = 30;

margins.left = 20;
margins.right = 20;
margins.top = 100;
margins.bottom = 100;

if (strcmp(article_name(1:2), './') || strcmp(article_name(1:3), '../'));
    article_name = [pwd '/' article_name];
end;

dot_idx = regexp(article_name, '/');
dirpath = article_name(1:dot_idx(length(dot_idx)));

tmp = dir([article_name, '.*.jtag']);

jt_paths = {tmp.name};
jt = jt_load([char(dirpath),char(jt_paths(1))],false);
pix = imread(jt.img_file);
pageheight = size(pix,1) - (margins.top + margins.bottom);
pagewidth = floor((size(pix,2)-(final_marg_l + final_marg_r))/2) - ...
            (margins.right + margins.left);
fprintf('Original pages were %i pixels wide.  Making cols %i pixels.\n', ...
        size(pix,2), pagewidth);

cols = reflow_article(article_name,pagewidth,pageheight,margins);
fprintf('Assigned col height is %i.\n', pageheight + margins.top + ...
        margins.bottom);

pages = []
colh = size(cols(1).ink,1);
colw = (size(cols(1).ink,1)+size(cols(2).ink,2))+final_marg_l+final_marg_r;
fprintf('Expected col height is %i.\n',colh);
for i=1:2:length(cols);
    if (i < length(cols));
        fprintf('Merging cols %i and %i, with heights %i and %i.\n', ...
                i,i+i, size(cols(i).ink,1), size(cols(i+1).ink,1));
        page.ink = [ones(colh,final_marg_l),cols(i).ink,cols(i+1).ink, ...
                    ones(colh,final_marg_r)];
        imshow(page.ink);
    else;
        page.ink = [ones(colh,final_marg_l),cols(i).ink, ...
                    ones(size(cols(i).ink)), ones(colh,final_marg_r)];
        imshow(page.ink);
    end;
    pages = [pages;page];
end;

res = pages;
