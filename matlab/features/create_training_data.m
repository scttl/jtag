function s = create_training_data(file_list, outfile)
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


% CVS INFO %
%%%%%%%%%%%%
% $Id: create_training_data.m,v 1.6 2004-07-29 20:41:56 klaven Exp $
% 
% REVISION HISTORY:
% $Log: create_training_data.m,v $
% Revision 1.6  2004-07-29 20:41:56  klaven
% Training data is now normalized if required.
%
% Revision 1.5  2004/07/27 21:57:57  klaven
% run_all_features now takes the path to the image file, rather than the pixels.  This will let us parse the file name to determine which page it is, and how many pages there are in the journal.
%
% Revision 1.4  2004/07/19 17:26:06  klaven
% *** empty log message ***
%
% Revision 1.3  2004/07/16 20:28:51  klaven
% Assorted changes made to accommodate memm.
%
% Revision 1.2  2004/07/01 16:45:50  klaven
% Changed the code so that we only need to extract the features once.  All testing functions work only with the extracted features now.
%
% Revision 1.1  2004/06/19 00:27:26  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.4  2004/06/08 00:56:49  klaven
% Debugged new distance and density features.  Added a script to make training simpler.  Added a script to print out output.
%
% Revision 1.3  2004/06/01 21:56:54  klaven
% Modified all functions that call the feature extraction methods to call them with all the rectanges at once.
%
% Revision 1.2  2003/08/22 15:13:11  scottl
% Updates to reflect the change to a cell array struct for class_name
%
% Revision 1.1  2003/08/18 14:56:00  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

jtag_extn = 'jtag';


% first do some argument sanity checking on the argument passed
error(nargchk(1,1,nargin));

if ~ iscellstr(file_list)
    error('FILE_LIST must be a cell array, each element of which is a string');
end

% initialize struct and fields
s.class_names = {};
s.num_pages = length(file_list);
s.pg_names = file_list;
[s.feat_names,s.feat_normalized] = run_all_features;
s.pg = {};
s.isSorted = false;



for i = 1:length(file_list)

  fprintf('File %i: %s\n', i, file_list{i});
  % parse file_name to determine name of jtag and jlog files
  dot_idx = regexp(file_list{i}, '\.');

  % load jtag file contents into struct
  pg_s = parse_jtag(strcat(file_list{i}(1:dot_idx(length(dot_idx))), ...
                           jtag_extn));

  feats = [];
  cids = [];
  %pixels = imread(pg_s.img_file);

  %all_features = run_all_features(pg_s.rects,pg_s.img_file);
  feats = run_all_features(pg_s.rects,pg_s.img_file);
  for j = 1:size(pg_s.rects,1)

      % run through each feature adding it to features
      %feats = [feats;all_features(j,:)];

      % convert the local classid for this rectangle to a global one, add it
      % to cid
      found = false;
      for k = 1:length(s.class_names)
          if strcmp(s.class_names{k}, ...
                    ddeblank(pg_s.class_name{pg_s.class_id(j)}))
              id = k;
              found = true;
              break;
          end
      end

      if ~ found
          % add the class to the global list of class names
          id = length(s.class_names) + 1;
          s.class_names{id} = ddeblank(pg_s.class_name{pg_s.class_id(j)});
      end

      cids = [cids; id];

  end

  s.pg{i}.cid = cids;
  s.pg{i}.features = feats;

end

s = update_td_class_names(s);

if (nargin == 2);
    dump_training_data(s,outfile);
end;



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
