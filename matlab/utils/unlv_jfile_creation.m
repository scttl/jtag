function unlv_jfile_creation(pg_file, img_dir, img_extn, varargin)
% UNLV_JFILE_CREATION  Creates jtag and jlog files for UNLV OCR ground truth
%
%  UNLV_JFILE_CREATION(PG_FILE, IMG_DIR, IMG_EXTN, OUT_DIR, [VAR1, VAL1],...)
%
%  PG_FILE should be the full path and name of a file listing the pages
%  to create jtag/jlog files for.  The files should be listed with '-' instead
%  of '_', and should not contain any extensions.  One file should be listed
%  per line.
%
%  IMG_DIR should be a string listing the path to the directory containing the 
%  images listed in PG_FILE.  The jtag and jlog files will be written to this
%  directory
%
%  IMG_EXTN must be a string containing the extension for the image files.  For
%  the UNLV data, this will typically be one of 3B, 4A, etc.
%


% CVS INFO %
%%%%%%%%%%%%
% $Id: unlv_jfile_creation.m,v 1.1 2007-01-02 17:13:18 scottl Exp $
%
% REVISION HISTORY
% $Log: unlv_jfile_creation.m,v $
% Revision 1.1  2007-01-02 17:13:18  scottl
% initial check-in.
%


% LOCAL VARS %
%%%%%%%%%%%%%%
%extension to use to denote zone information
zone_extn = 'Z';

%mode to be used
mode = 'crop';

%default snapped value
snapped = 0;

%default selection time value
sel_time = 0;

%default class dragging time value
class_time = 0;

%default number of classification attempts
class_attempts = 1;

%default number of resize attempts
resize_attempts = 0;

%default ordered list of classe names to use
classes = {'section_heading', ...
    'subsection_heading', ...
    'footer', ...
    'references', ...
    'start_of_page', ...
    'bullet_item', ...
    'table_label', ...
    'header', ...
    'authour_list', ...
    'code_block', ...
    'main_title', ...
    'figure_label', ...
    'figure', ...
    'image', ...
    'text', ...
    'equation', ...
    'footnote', ...
    'figure_caption', ...
    'decoration', ...
    'abstract', ...
    'end_of_page', ...
    'table', ...
    'graph', ...
    'eq_number', ...
    'editor_list', ...
    'table_caption', ...
    'pg_number'};

map_names = {'Caption', 'Footnote', 'Header/Footer', 'Other_Text', 'Table', ...
             'Text'};
map_vals = [18,17,8,15,22,15];

%value to assign when a zone type doesn't match any of the classes
default_map = 15;  %this is text in the default list

% CODE START %
%%%%%%%%%%%%%%
%argument sanity checking
if nargin < 3
    error('incorrect number of arguments passed');
elseif nargin > 3
    process_optional_args(varargin{:});
end
if ~ exist(img_dir, 'dir')
    error('img directory: %s passed does not exist', img_dir);
end

%read the list of images from the page file
imgs = textread(pg_file, '%s');
num_imgs = length(imgs);
%convert any  '-' in the listed files to '_'
imgs = regexprep(imgs, '-', '_');

%loop and read the zone information from each file in the list (if it exists)
for ii=1:num_imgs
    s.img_file = [img_dir, '/', imgs{ii}, '.', img_extn];
    s.jtag_file = [img_dir, '/', imgs{ii}, '.jtag'];
    s.jlog_file = [img_dir, '/', imgs{ii}, '.jlog'];
    s.class_name = classes;
    [l,t,w,h,class_list] = textread([s.img_file, zone_extn],'%d%d%d%d%s');
    num_zones = length(l);
    s.rects = [l,t,l+w-1,t+h-1];
    s.class_id = zeros(num_zones,1) + default_map;
    for jj=1:num_zones
        idx = find(strcmp(map_names, class_list{jj}));
        if ~isempty(idx)
            s.class_id(jj) = map_vals(idx(1));
        end
    end
    s.mode = cell(num_zones,1);
    [s.mode{:}] = deal(mode);
    s.snapped = zeros(num_zones,1) + snapped;
    s.sel_time = zeros(num_zones,1) + sel_time;
    s.class_time = zeros(num_zones,1) + class_time;
    s.class_attempts = zeros(num_zones,1) + class_attempts;
    s.resize_attempts = zeros(num_zones,1) + resize_attempts;

    %write the struct to disk
    if ~ jt_save(s)
        error('problem creating jtag file for %s', s.img_file);
    end
end



% SUBFUNCTION DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
