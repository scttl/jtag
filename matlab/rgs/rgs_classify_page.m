function cids = rgs_classify_page(jt,params,showit);

global class_names;

if (ischar(jt));
    jt = jt_load(jt,0);
end;

pix = imread(jt.img_file);

feats = rgs_get_features(pix,jt.rects,jt.img_file);

lls=rgs_region_ll(feats.vals,params);
[m,i] = max(lls');
cids = i;
if (nargin >=3) && showit;
    [class_names(i)' class_names(get_cid(jt.class_name(jt.class_id)))']
end;
