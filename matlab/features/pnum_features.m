function res = pnum_features(rects, pixels, img_fpath)
%
%function res = pnum_features(rects, pixels, img_fpath)
%
% Returns features related to the number of pages in the article.
%

res(1,1).name = 'is_first_page';
res(1,1).norm = true;
res(1,2).name = 'is_last_page';
res(1,2).norm = true;
res(1,3).name = 'in_last_15pct_of_pages';
res(1,3).norm = true;
res(1,4).name = 'pnum_over_numpages';
res(1,4).norm = true;

if (nargin == 0);
    get_names = true;
    return;
else
    get_names = false;
end;

dot_idx = regexp(img_fpath, '\.');

if (length(dot_idx) < 2);
    res(1,1:4).val = 0;
else
    img_ext = img_fpath((dot_idx(end)+1):end);
    art_path = img_fpath(1:(dot_idx(end-1)));
    tmp = dir([art_path '*.' img_ext]);
    art_fnames = {tmp.name};
    numpages = length(art_fnames);

    tmp = dir(img_fpath);
    pg_realpath = tmp(1).name;
    
    pnum = find(strcmp(art_fnames,pg_realpath));

    res(1,1).val = (pnum == 1);
    res(1,2).val = (pnum == numpages);
    res(1,3).val = ((pnum/numpages)>=0.85);
    if (numpages == 1);
        res(1,4).val = 0;
    else;
        res(1,4).val = ((pnum-1)/(numpages-1));
    end;
end;
    

for rr=1:size(rects,1);
    res(rr,:) = res(1,:);
end;


