function [jt,segs] = ltc_runshow(jtpath);

wpath = './ltc-test1.lr.mat';
w = parse_lr_weights(wpath);

jt = jt_load(jtpath);

pix = imread(jt.img_file);

segs = ltc_cut_file(jt,w,pix);

seg_plot(pix,segs);
