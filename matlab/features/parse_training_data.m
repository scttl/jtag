function s = parse_training_data(file)
% PARSE_TRAINING_DATA  Reads the contents of the td file passed into a structure
%                      array.
%
%   S = PARSE_TRAINING_DATA(FILE)  Attempts to validate and open FILE passed, 
%   reading its header and page information into fields of structure S as 
%   follows:
%
%     s.class_names -> cell array whose entries represent the string name of
%                      the class associated with that entry number
%     s.num_pages   -> scalar giving the total number of pages examined in the
%                      training set
%     s.pg_names    -> cell array whose entries represent the string name of
%                      the page image.  This is identical to file_list passed
%     s.feat_names  -> cell array whose entries list the string names of each
%                      of the features tested on each selection below
%     s.pg          -> cell array whose entries are structs, representing all
%                      information for a given page.
%
%   Furthermore, each struct i in s.pg (access via s.pg{i})  is arranged as 
%   follows:
%
%     s.pg{i}.cid      -> vector of class id #'s one entry for each selection
%                         on the page.  These values correspond to which entry 
%                         in s.class_names the selection was classified as.
%     s.pg{i}.features -> matrix containing one row for each selection on the 
%                         page.  Each column entry corresponds to the results 
%                         of running that selection on one feature.
%
%   If there is a problem at any point during file parsing or structure
%   creation, an appropriate error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: parse_training_data.m,v 1.3 2004-07-20 02:21:48 klaven Exp $
% 
% REVISION HISTORY:
% $Log: parse_training_data.m,v $
% Revision 1.3  2004-07-20 02:21:48  klaven
% Changing training data format from text to .mat
%
% Revision 1.2  2004/07/16 20:28:53  klaven
% Assorted changes made to accommodate memm.
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.1  2003/08/20 21:22:35  scottl
% Initial revision.
%

% New version of save routine stores s in a .mat file.
if (strcmp(file(end-3:end), '.mat'));
    evalstr = ['load ' file ';'];
    eval(evalstr);
    s = saveddatavar;
    return;
end;

% If it is not a .mat file, try the old loading routine.


% LOCAL VARS %
%%%%%%%%%%%%%%

% training data file specifics (update these as the td file spec. changes)
separator = '---';  % used to denote the start of a page of data
s.class_names = {};
s.num_pages = 0;
s.pg_names = {};
s.feat_names = {};
s.pg = {};
s.isSorted = false;

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

    if strcmp(line{1}, separator)
        break;
    elseif strcmp(line{1}, 'class_names')
        for i = 2:size(line,1)
            s.class_names{str2num(line{i,1})} = line{i,2};
        end
    elseif strcmp(line{1}, 'feat_names')
        for i = 2:size(line,1)
            s.feat_names{str2num(line{i,1})} = line{i,2};
        end
    elseif strcmp(line{1}, 'num_pages')
        s.num_pages = str2num(line{2,1});
    elseif strcmp(line{1}, 'label_feats_added')
        s.label_feats_added = str2num(line{2,1});
    end
end


% now loop to parse and add each of the selections, should be in multiples
% of 2 (3 including the separator)
curr = 1;
while ~ feof(fid)

    line = parse_line(fid);

    if ~ strcmp(line{1}, 'pg_name')
        error(strcat('Did not find pg_name at start of selection.  Found:', ...
              line{1}, ' instead.'));
    end

    s.pg_names{curr} = line{2};

    line = parse_line(fid);
    if feof(fid)
        error('did not find complete page selection when EOF reached');
    end

    if ~ strcmp(line{1,1}, 'pg_data')
        error(strcat('Did not find pg_data next in selection.  Found:', ...
              line{1,1}, ' instead.'));
    end

    for i = 2:size(line,1)
        s.pg{curr}.cid(i-1,1) = str2num(line{i,1});
        for j = 2:size(line,2)
            s.pg{curr}.features(i-1,j-1) = str2double(line{i, j});
        end
    end

    line = parse_line(fid);
    if ~ feof(fid) & ~ strcmp(line{1,1}, separator)
        error(strcat('Did not find separator next in selection.  Found:', ...
              line{1,1}, ' instead.'));
    end

    curr = curr + 1;

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


