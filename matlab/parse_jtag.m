function s = parse_jtag(file)
% PARSE_JTAG    Reads the contents of the jtag file passed into a structure
%               array.
%
%   Attempts to validate and open FILE passed, reading its header and selection
%   information into fields of structure S as follows:
%
%     s.jtag_file -> the full path and name to the .jtag file used to create s
%     s.img_file  -> the full path and name to the associated image file
%     s.<class_1>
%      ...        -> each of <class_1> etc. is replaced by a class name and 
%     s.<class_n>    will contain a vector of selections for that specific
%                    class.  Each element in the vector will be a structure
%                    that has the following fields (assuming looking at the
%                    j'th element of vector belonging to <class_i>:
%        
%          s.<class_i>(j).rect -> 4 element column vector giving left, top, 
%                                 right,bottom pixel co-ords of its bounding box
%
%   If there is a problem at any point during file parsing or structure
%   creation, an appropriate error is returned to the caller.


% CVS INFO %
%%%%%%%%%%%%
% $Id: parse_jtag.m,v 1.1 2003-07-23 16:23:01 scottl Exp $
% 
% REVISION HISTORY:
% $Log: parse_jtag.m,v $
% Revision 1.1  2003-07-23 16:23:01  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

% jtag file specifics (update these as the jtag file spec. changes)
separator = '---';  % used to denote the start of a selection
img_prefix = 'img'; % used to denote the path and name of the image file
                    % associated with this jtag file

% first do some argument sanity checking on the argument passed
error(nargchk(1,1,nargin));

[r, c] = size(file);

if iscell(file) | ~ ischar(file) | r ~= 1
    error('FILE must contain a single string.');
end

% attempt open the arg and read in its header information
fid = fopen(file);

if fid == -1
    error('unable to open FILE.');
end

s.jtag_file = file;

while ~ feof(fid)

    line = parse_line(fgetl(fid));

    if isempty(line)
        continue;
    elseif strcmp(deblank(line(1,:)), separator)
        break;
    elseif strcmp(deblank(line(1,:)), img_prefix)
        s.img_file = deblank(line(2,:));
    end

end

% now loop to parse and add each of the selections, should be in multiples
% of 3 (4 including the separator)
while ~ feof(fid)

    class_line = parse_line(fgetl(fid));
    pos_line = parse_line(fgetl(fid));
    mode_line = parse_line(fgetl(fid));

    class_name = deblank(class_line(2,:));
    data = struct('rect', str2num([pos_line(2:5,:)]));

    if ~ isfield(s, class_name)
        % first entry for this class
        r = 1;
    else
        [r, c] = size(class_name);
        r = r + 1;
    end

    evalc(['s.' class_name '(r) = data']);

    % next line must be a separator (if more lines exist)
    fgetl(fid);

end

% close the file
fclose(fid);



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = parse_line(in)
% PARSE_LINE subfunction that takes a single line, strips its comments,
%            removes the '=' character if it exists, and returns all of its 
%            remaining non-whitespace elements as elemnts of a column array (or 
%            the empty string if IN is blank).

if ~ ischar(in)
    error('IN is not a string.');
end

if isempty(in)
    res = in;
    return;
else
    res = [];
end

% strip all characters after (and including) the comment char
commentpos = regexp(in, '#', 'once');
if ~ isempty(commentpos)
    if commentpos > 1
       in = ddeblank(in(1 : commentpos - 1));
    else
       return;
    end
end

% loop over each whitespace delimited token, adding it to res (drop the '=')
% though
[curr, rest] = strtok(in);
while ~ isempty(rest)
    if ~ strcmp(ddeblank(curr), '=')
        res = strvcat(res, curr);
    end
    [curr, rest] = strtok(rest);
end
if ~ strcmp(ddeblank(curr), '=')
    res = strvcat(res, curr);
end
