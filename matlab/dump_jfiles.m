function res = dump_jfiles(s)
% DUMP_JFILES    Formats and writes out the contents of the structure S to a
%               jtag and jlog file.
%
%   RES = DUMP_JFILES(S)  Attempts to read the contents of struct S (formatted
%   along the lines of that returned by PARSE_JTAG and PARSE_JLOG), writing
%   out its data to the jtag and jlog files specified in the fields
%   s.jtag_file and s.jlog_file.  If successful, RES is set to 1.  Upon any
%   failure, an error is returned and RES is set to 0.
%
%   SEE ALSO   PARSE_JTAG PARSE_JLOG


% CVS INFO %
%%%%%%%%%%%%
% $Id: dump_jfiles.m,v 1.1 2003-08-12 22:25:32 scottl Exp $
% 
% REVISION HISTORY:
% $Log: dump_jfiles.m,v $
% Revision 1.1  2003-08-12 22:25:32  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% jtag and jlog file header prefixes
hpre_img = 'img';
hpre_type = 'type';
hpre_res = 'resolution';
hpre_cksum = 'cksum';

% jtag file specifics (update these as the jtag file spec. changes)
num_bt_fields = 4;
btpre_class = 'class';
btval_class = 'text'; % default value if s.class_id and s.class_name not avail
btpre_pos = 'pos';
btpre_mode = 'mode';
btval_mode = 'crop'; % default value if s.mode not present
btpre_snapped = 'snapped';
btval_snapped = 0; % default value if s.snapped not present

% jlog file specifics (update these as the jlog file spec. changes)
num_bl_fields = 5;
blpre_pos = 'pos';
blpre_slt = 'sel_time';
blval_slt = 0.; % default value if s.sel_time not present
blpre_clt = 'class_time';
blval_clt = 0.; % default value if s.class_time not present
blpre_ca = 'class_attempts';
blval_ca = 1; % default value if s.class_attempts not present
blpre_ra = 'resize_attempts';
blval_ra = 0; % default value if s.resize_attempts not present

separator = '---';  % used to denote the start of a selection
res = false;

% first do some argument sanity checking on the argument passed
error(nargchk(1,1,nargin));

% ensure that the struct has atleast the minimum required fields
if ~ isfield(s, 'img_file') | ~ isfield(s, 'rects') | ...
   ~ isfield(s, 'jtag_file') | ~ isfield(s, 'jlog_file')
    error('invalid struct passed.  See PARSE_JTAG and PARSE_JLOG for info');
end

pixels = imread(s.img_file);

% calculate and store the header information
img_type = imfinfo(s.img_file);
img_type = img_type.Format;

% flip required for res since in <width>x<height> <--> <cols>x<rows> form
img_res = sprintf('%dx%d', fliplr(size(pixels))); 

[dummy, img_cksum] = unix(['cksum ' s.img_file]);
img_cksum = strtok(img_cksum);

header = char(hpre_img, s.img_file, hpre_type, img_type, hpre_res, img_res, ...
              hpre_cksum, img_cksum);

%@@ dump out class names/colours and other config info??
% config = 

% setup our jtag value fields
if isfield(s, 'class_id') & isfield(s, 'class_name') & ...
         size(s.class_id,1) == size(s.rects,1)
    btval_class = s.class_name(s.class_id,:);
else
    btval_class = repmat(btval_class, size(s.rects,1), 1);
end

if isfield(s, 's.mode') & size(s.mode,1) == size(s.rects,1)
    btval_mode = s.mode;
else
    btval_mode = repmat(btval_mode, size(s.rects,1), 1);
end

if isfield(s, 's.snapped') & size(s.snapped,1) == size(s.rects,1)
    btval_snapped = s.snapped;
else
    btval_snapped = repmat(btval_snapped, size(s.rects,1), 1);
end

% now build up the jtag selections
jtag_sels = [];
for i = 1:size(s.rects,1)
    jtag_sels = strvcat(jtag_sels, btpre_class, btval_class(i,:), btpre_pos, ...
    int2str(s.rects(i,:)), btpre_mode, btval_mode(i,:), btpre_snapped, ...
    int2str(btval_snapped(i)));
end

% setup our jlog value fields
if isfield(s, 'sel_time') & size(s.sel_time,1) == size(s.rects,1)
    blval_slt = s.sel_time;
else
    blval_slt = repmat(blval_slt, size(s.rects,1), 1);
end

if isfield(s, 'class_time') & size(s.class_time,1) == size(s.rects,1)
    blval_clt = s.class_time;
else
    blval_clt = repmat(blval_clt, size(s.rects,1), 1);
end

if isfield(s, 'class_attempts') & size(s.class_attempts,1) == size(s.rects,1)
    blval_ca = s.class_attempts;
else
    blval_ca = repmat(blval_ca, size(s.rects,1), 1);
end

if isfield(s, 'resize_attempts') & size(s.resize_attempts,1) == size(s.rects,1)
    blval_ra = s.resize_attempts;
else
    blval_ra = repmat(blval_ra, size(s.rects,1), 1);
end

% build up jlog data
jlog_sels = [];
for i = 1:size(s.rects,1)
    jlog_sels = strvcat(jlog_sels, blpre_pos, int2str(s.rects(i,:)), ...
    blpre_slt, num2str(blval_slt(i)), blpre_clt, num2str(blval_clt(i)), ...
    blpre_ca, int2str(blval_ca(i)), blpre_ra, int2str(blval_ra(i)));
end

% write out the jtag file
jtag_fid = fopen(s.jtag_file, 'w');
for i = 1:2:size(header)
    fprintf(jtag_fid, '%s = %s\n', header(i,:), header(i+1,:));
end
for i = 1:(num_bt_fields * 2):size(jtag_sels)
    fprintf(jtag_fid, '%s\n%s = %s\n%s = %s\n%s = %s\n%s = %s\n%s = %s\n', ...
        separator, jtag_sels(i,:), jtag_sels(i+1,:), jtag_sels(i+2,:), ...
        jtag_sels(i+3,:), jtag_sels(i+4,:), jtag_sels(i+5,:), ...
        jtag_sels(i+6,:), jtag_sels(i+7,:));
end
fclose(jtag_fid);

% write out the jlog file
jlog_fid = fopen(s.jlog_file, 'w');
for i = 1:2:size(header)
    fprintf(jlog_fid, '%s = %s\n', header(i,:), header(i+1,:));
end
for i = 1:(num_bl_fields * 2):size(jlog_sels)
    fprintf(jlog_fid, '%s\n%s = %s\n%s = %s\n%s = %s\n%s = %s\n%s = %s\n', ...
        separator, jlog_sels(i,:), jlog_sels(i+1,:), jlog_sels(i+2,:), ...
        jlog_sels(i+3,:), jlog_sels(i+4,:), jlog_sels(i+5,:), ...
        jlog_sels(i+6,:), jlog_sels(i+7,:), jlog_sels(i+8,:), jlog_sels(i+9,:));
end
fclose(jlog_fid);


% since everything went ok, return true
res = true;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
