function [samples,fnames] = ltc3_create_td(file_list, outfile);
% CREATE_TRAINING_DATA    Builds up a struct containing all necessary training
%                         data information, from the list of image files passed 
%                         in.  If outfile is given, saves the structure to
%                         this file.
%
%   S = CREATE_TRAINING_DATA(FILE_LIST)  Attempts to build up a corpus of
%   training data on the list of valid image files passed in FILE_LIST (one
%   file per cell array element).  Each of these files must have an associated 
%   jtag file containing the image name and rectangle information at a minimum. 
%   The training data is stored in the struct S as follows:
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
%     s.pg{i}.rects    -> (n x 4) matrix of segments:
%                             [L T R B;
%                              L T R B]


% LOCAL VARS %
%%%%%%%%%%%%%%

jtag_extn = 'jtag';

[junk,fnames] = ltc3_make_samples_from_cands();

if ~ iscellstr(file_list)
    error('FILE_LIST must be a cell array, each element of which is a string');
end

tic;
samples = [];
for i = 1:length(file_list)

  fprintf('File %i: %s,  t=%i\n', i, file_list{i}, floor(toc));
  % parse file_name to determine name of jtag and jlog files
  dot_idx = regexp(file_list{i}, '\.');

  % load jtag file contents into struct
  jt = parse_jtag(strcat(file_list{i}(1:dot_idx(length(dot_idx))), ...
                           jtag_extn));

  samps = ltc3_create_samples_from_file(jt);

  samples = [samples;samps];
end;

if (nargin >= 2);
  evalstr = ['save ' char(outfile) ' samples fnames;'];
  eval(evalstr);
end;

