function features = rgs_get_features(pix,segs,img_path);

use.dist = true;
use.snap = false;
use.pnum = true;
use.dens = true;
use.mark = false;
use.ocr = false;

feats_to_keep = rgs_feats_to_use();

is_gaus = rgs_gaus_feats();

is_bool = rgs_bool_feats();

fnames = run_all_features([],[],use,true);
fnames = fnames(feats_to_keep);

if (nargin > 0);
    feats = run_all_features(segs,img_path,use);

    feats = feats(:,feats_to_keep);

    features.names = fnames;
    features.vals = feats;
    features.is_gaus = is_gaus;
    features.is_bool = is_bool;
else;
    features = fnames;
end;
