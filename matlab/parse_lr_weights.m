function w = parse_lr_weights2(file)
% PARSE_LR_WEIGHTS  Reads the contents of the logistic regression weight file 
%                   passed into a structure array.
%
%   W = PARSE_LR_WEIGHTS(FILE)  Attempts to validate and open FILE passed, 
%   reading its information into a structure w as follows:
%
%     w.class_names -> cell array whose entries represent the string name of
%                      the class associated with that entry number
%     w.weights   -> MxN matrix of floating point numbers, where each M (row)
%                    represents a class (size(M) == size(w.class_names)), and
%                    each of the N columns corresponds to a weight value
%                    (coefficient) for that feature.
%
%   If there is a problem at any point during file parsing or structure
%   creation, an appropriate error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: parse_lr_weights.m,v 1.2 2004-06-14 20:20:06 klaven Exp $
% 
% REVISION HISTORY:
% $Log: parse_lr_weights.m,v $
% Revision 1.2  2004-06-14 20:20:06  klaven
% Changed the load and save routines for lr weights to be more general, allowing me to add more fields to the weights data structure.  Also added a record of the log likelihood progress to the weights data structure.
%
% Revision 1.1  2003/09/22 17:47:31  scottl
% Initial revision.
%

% New version of save routine stores w in a .mat file.
if (strcmp(file(end-3:end;), '.mat'));
    evalstr = ['load ' file ';'];
    eval(evalstr);
    w = savedweightvar;
    return;
end;

% If it is not a .mat file, try the old loading routine.

% LOCAL VARS %
%%%%%%%%%%%%%%

% lr weights file specifics (update these as the weights file spec. changes)
w.class_names = {};
w.weights = [];
w.feature_names = {};

% first do some argument sanity checking on the argument passed
error(nargchk(1,1,nargin));

if iscell(file) | ~ ischar(file) | size(file,1) ~= 1
    error('FILE must contain a single string.');
end

% attempt to open the arg, and read in header information
fid = fopen(file);

if fid == -1
    error('unable to open FILE.');
end

% read all the header data
while ~ feof(fid)

    line = parse_line(fid);

    if iscell(line) & strcmp(line{1}, 'class_names')
        for i = 2:size(line,1)
            w.class_names{str2num(line{i,1})} = line{i,2};
        end
    elseif iscell(line) & strcmp(line{1}, 'weights')
        for i = 2:size(line,1)
            for j = 1:size(line,2)
                w.weights(i-1,j) = str2double(line{i,j});
            end
        end
    end
end


% close the file
fclose(fid);



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = parse_line(fid)
% PARSE_LINE subfunction that takes a file descriptior and reads a line, 
%            strips its comments, removes the '=' character if it exists, 
%            joins multiple lines, and  returns all of its remaining 
%            non-whitespace elements as elements of a cell array, split into 
%            rows and columns by the appropriate separators.
%
%            If the end-of-file marker is reached, -1 is returned to the
%            caller, if an empty line is encountered, it is skipped and the
%            next line is read.

comment = '%';
mul_line_beg = '\[';
mul_line_end = '\]';
row_sep = '=|;';
col_sep = ':|,';

in = fgetl(fid);

if feof(fid)
    res = in;
    return;
elseif isempty(in)
    res = parse_line(fid);
else
    res = {};
end

% strip all characters after (and including) the comment char
commentpos = regexp(in, comment, 'once');
if ~ isempty(commentpos)
    if commentpos > 1
       in = ddeblank(in(1 : commentpos - 1));
    else
       % read the next line since empty
       in = '';
       res = parse_line(fid);
    end
end

% check if we have to glue lines together
ml_beg_pos = regexp(in, mul_line_beg, 'once');
if ~ isempty(ml_beg_pos)
    in(ml_beg_pos) = ' ';
    ml_end_pos = regexp(in, mul_line_end, 'once');

    while isempty(ml_end_pos)
        next_in = fgetl(fid);
        if feof(fid)
            break;
        end
        in = strcat(in, next_in);
        ml_end_pos = regexp(in, mul_line_end, 'once');
    end

    if ~ isempty(ml_end_pos)
        in(ml_end_pos) = ' ';
    end
end

% break up the line into rows and columns based on separators found.
row_pos = regexp(in, row_sep);
col_pos = regexp(in, col_sep);
row = 1;
col = 1;
prev = 1;

if isempty(row_pos) & isempty(col_pos) & ~ isempty(in)
    % no separators etc. found, copy line directly
    res{row,col} = in;
end

while ~ (isempty(row_pos) & isempty(col_pos))
    if isempty(col_pos) | ...
       (~ isempty(row_pos) & ~ isempty(col_pos) & row_pos(1) <= col_pos(1))
        res{row,col} = ddeblank(in(prev:row_pos(1) - 1));
        prev = row_pos(1) + 1;
        row_pos = row_pos(2:end);
        col = 1;
        row = row + 1;
    else
        res{row,col} = ddeblank(in(prev:col_pos(1) - 1));
        prev = col_pos(1) + 1;
        col_pos = col_pos(2:end);
        col = col + 1;
    end

    if isempty(row_pos) & isempty(col_pos) & prev < length(in)
        res{row,col} = ddeblank(in(prev:length(in)));
    end
end


