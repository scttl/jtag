function res = classify_pg(class_names, img_file, class_fn, varargin)
% CLASSIFY_PG    Attempts to find and classify each rectangular subrectangle
%                of IMG_FILE as one of the clases in CLASS_NAMES by running 
%                the CLASS_FN algorithm.
%
%   RES = CLASSIFY_PG(CLASS_NAMES, IMG_FILE, CLASS_FN, {ARGS})  Opens the 
%   IMG_FILE passed, then determines a collection of rectangular subregions 
%   using the xycut algorithm.  Each subregion is then classified 
%   as one of the classes listed in CLASS_NAMES using the classification 
%   algorithm defined by CLASS_FN and any additional arguments in ARGS.
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
% $Id: classify_pg.m,v 1.5 2004-01-19 01:44:57 klaven Exp $
% 
% REVISION HISTORY:
% $Log: classify_pg.m,v $
% Revision 1.5  2004-01-19 01:44:57  klaven
% Updated the changes made over the last couple of months to the CVS.  I really should have learned how to do this earlier.
%
% Revision 1.4  2003/09/19 15:27:08  scottl
% Updates to remove always passing training data.  Now it is an optional
% argument since it is only needed for knn_fn.
%
% Revision 1.3  2003/09/11 18:25:23  scottl
% Amended previous fix, to ensure that rectangles are found, if none currently
% exist in the jtag file.
%
% Revision 1.2  2003/09/11 17:47:09  scottl
% Allowed use of existing rectangles (if found) to be used for classification.
%
% Revision 1.1  2003/08/26 20:36:24  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

disp('Trying to classify page');

jtag_extn = 'jtag';  %jtag filename extension
jlog_extn = 'jlog';  %jlog filename extension

s = [];  % the structure we will build as we classify the rectangles

% first do some sanity checking on the arguments passed
error(nargchk(3,inf,nargin));

if ~iscell(class_names) | size(class_names,1) ~= 1
    error('CLASS_NAMES must be a cell array listing one class per column');
end
if iscell(img_file) | ~ ischar(img_file) | size(img_file,1) ~= 1
    error('IMG_FILE must contain a single string.');
end

% initialize components of the structure
s.class_name = class_names;
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
    if size(tmp_struct.rects,1) < 1
        error
    end
    s.rects = tmp_struct.rects;
catch
    rects = xycut(img_file);
    % rects = dist_img(img_file);
    % rects = dist_img_red(img_file);
    disp(strcat('Found ', int2str(size(rects,1)), ' rectangles'));
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
        s.class_id(i,:) = feval(class_fn, s.class_name, features, varargin{:});
    else
        s.class_id(i,:) = feval(class_fn, s.class_name, features);
    end
end

% dump the results out to jtag and jlog files
res = dump_jfiles(s);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
