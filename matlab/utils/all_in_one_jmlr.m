function jt = all_in_one_jmlr(url,targetdir);

if (strcmp(targetdir(1:2), './') || strcmp(targetdir(1:3), '../'));
    targetdir = [pwd '/' targetdir];
end;

global class_names;
global use;

use.dist = true;
use.snap = false;
use.pnum = true;
use.dens = true;
use.mark = false;
wpath='/h/40/klaven/jtag/matlab/results/nosnap/nosnap-jmlr-train.lr.mat';

slash_idx = regexp(url, '/');
filebase = url((slash_idx(end)+1):end);

dot_idx = regexp(filebase,'\.');
fileext = filebase((dot_idx(end)+1):end);
filebase = filebase(1:(dot_idx(end)-1));

if (length(targetdir) >= 1);
    evalstr = ['!wget -nH -nd -nc -P' targetdir ' ' url];
else;
    evalstr = ['!wget -nH -nd -nc ' url];
end;
eval(evalstr);

if (strcmp(fileext, 'pdf'));
    evalstr = ['!gs -sDEVICE=tiffg4 -dBATCH -q -dNOPAUSE -sOutputFile=' ...
               targetdir filebase '.ps ' targetdir filebase '.' fileext];
    eval(evalstr);
    fileext = 'ps';
end;

evalstr = ['!./utils/tiffsplit ' targetdir filebase '.' fileext ' ' ...
           targetdir filebase '.'];
eval(evalstr);

%Now, we need to create the .jtag files for each of the .tiff files

tmp = dir([targetdir filebase '.*.tif']);
tiff_files = {tmp.name};

for ii = 1:length(tiff_files);
    fprintf('Processing file %i of %i\n',ii,length(tiff_files));
    s = [];
    s.img_file = [targetdir char(tiff_files(ii))];
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

fprintf(['Load article ' targetdir filebase '\n']);
load_article([targetdir filebase]);


