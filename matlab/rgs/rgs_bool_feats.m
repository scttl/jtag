function bf = rgs_bool_feats();

bool_feats = [14 15 16 17 18 19 20 21 22 39 40 42 43 44];
is_bool = zeros(1,45);
is_bool(bool_feats) = 1;
is_bool = is_bool(rgs_feats_to_use());
bf = is_bool;
