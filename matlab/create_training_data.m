function s = create_training_data(file_list)
% CREATE_TRAINING_DATA    Builds up a struct containing all necessary training
%                         data information, from the list of image files passed 
%                         in.
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
% $Id: create_training_data.m,v 1.3 2004-06-01 21:56:54 klaven Exp $
% 
% REVISION HISTORY:
% $Log: create_training_data.m,v $
% Revision 1.3  2004-06-01 21:56:54  klaven
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
s.feat_names = run_all_features;
s.pg = {};

for i = 1:length(file_list)

  % parse file_name to determine name of jtag and jlog files
  dot_idx = regexp(file_list{i}, '\.');

  % load jtag file contents into struct
  pg_s = parse_jtag(strcat(file_list{i}(1:dot_idx(length(dot_idx))), ...
                           jtag_extn));

  feats = [];
  cids = [];
  pixels = imread(pg_s.img_file);

  all_features = run_all_features(pg_s.rects,pixels);
  for j = 1:size(pg_s.rects,1)

      % run through each feature adding it to features
      feats = all_features(j,:);

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



% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
