function gf = rgs_gaus_feats();

gaus_feats = [1 2 3 4 5 6 7 8 9 10 11 12 13 36 37 38 41 45]; % 46 ... 
%              47 48 49 50 51 52 53 54 55 56 57 58 59];
is_gaus = zeros(1,45);
is_gaus(gaus_feats) = 1;
is_gaus = is_gaus(rgs_feats_to_use());
gf = is_gaus;
