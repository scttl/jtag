function res = jt_runbatch(targetdir,wpath);

tmp = dir([targetdir '/*.tif']);
tiff_files = {tmp.name};
tmp = dir([targetdir '/*.tiff']);
tiff_files = [tiff_files, {tmp.name}];

global class_names;
%jt_runbatch('/p/learning/klaven/Journals/TAGGING/nips_2001','./results/nosnap/nosnap-nips-train-lr.mat');
for ii = 1:length(tiff_files);
    fprintf('Processing file %i of %i\n',ii,length(tiff_files));
    s = [];
    s.img_file = [targetdir '/' char(tiff_files(ii))];
    dot_idx = regexp(s.img_file,'\.');
    s.jtag_file = [s.img_file(1:(dot_idx(end))) 'jtag'];
    s.rects = [];
    s.class_id = [];
    s.class_name = {};
    s.mode = {};
    s.snapped = [];
    s.jlog_file = [s.img_file(1:(dot_idx(end))) 'jlog'];
    s.sel_time = zeros(0,1);
    s.class_time = zeros(0,1);
    s.class_attempts = zeros(0,1);
    s.resize_attempts = zeros(0,1);
    
    dump_jfiles(s);
    
    classify_pg(class_names, s.img_file, 'lr_fn', wpath);
end;

res = 1;

