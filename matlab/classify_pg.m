function res = classify_pg(data, img_file, class_fn, varargin)
% CLASSIFY_PG    Attempts to find and classify each rectangular subrectangle
%                of IMG_FILE by running the CLASS_FN algorithm against all the 
%                training data in DATA passed.
%
%   RES = CLASSIFY_PG(DATA, IMG_FILE, CLASS_FN, {ARGS})  Opens the IMG_FILE 
%   passed, then determines a collection of rectangular subregions using the 
%   xycut algorithm and a line detector.  Each subregion is then classified 
%   against the training data struct DATA (see CREATE_TRAINING_DATA for its 
%   format) using the classification algorithm defined by CLASS_FN and any
%   additional arguments in ARGS.
%
%   Once the rectangles have been classified, the information is dumped out to
%   the appropriate jtag and jlog files, overwriting any existing files.
%
%   If there is a problem at any point an error is returned.  On success res
%   is set to 1, and 0 otherwise.
%
%   See also:  CREATE_TRAINING_DATA


% CVS INFO %
%%%%%%%%%%%%
% $Id: classify_pg.m,v 1.2 2003-09-11 17:47:09 scottl Exp $
% 
% REVISION HISTORY:
% $Log: classify_pg.m,v $
% Revision 1.2  2003-09-11 17:47:09  scottl
% Allowed use of existing rectangles (if found) to be used for classification.
%
% Revision 1.1  2003/08/26 20:36:24  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

jtag_extn = 'jtag';  %jtag filename extension
jlog_extn = 'jlog';  %jlog filename extension

s = [];  % the structure we will build as we classify the rectangles

% first do some sanity checking on the arguments passed
error(nargchk(3,inf,nargin));

if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
    error('IMG_FILE must contain a single string.');
end

% initialize components of the structure
s.class_name = data.class_names;
s.img_file = img_file;
s.rects = [];

res = nan;

% attempt to open and load the pixel contents of IMG_FILE passed (to ensure it
% exists)
pixels = imread(img_file);

% parse file_name to determine name of jtag and jlog files
dot_idx = regexp(img_file, '\.');
s.jtag_file = strcat(img_file(1:dot_idx(length(dot_idx))), jtag_extn);
s.jlog_file = strcat(img_file(1:dot_idx(length(dot_idx))), jlog_extn);

% get the list of rectangles to classify, first see if they already exist in a
% jtag file, otherwise build them from scratch
try
    tmp_struct = parse_jtag(s.jtag_file);
    s.rects = tmp_struct.rects;
catch
    rects = xycut(img_file);
    for i = 1:size(rects,1)
        % s.rects = [s.rects; line_detect(pixels, rects(i,:))];
        s.rects(i,:) = get_sr(rects(i,:), pixels);
    end
end

% loop to classify each reactangle
for i = 1:size(s.rects,1)
    % run through all features for this rectangle
    features = run_all_features(s.rects(i,:), pixels);
    if ~isempty(varargin)
        s.class_id(i,:) = feval(class_fn, data, features, varargin{:});
    else
        s.class_id(i,:) = feval(class_fn, data, features);
    end
end

% dump the results out to jtag and jlog files
res = dump_jfiles(s);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
