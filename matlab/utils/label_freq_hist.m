function res = label_freq_hist(data, varargin)
% LABEL_FREQ_HIST    Reads counts of the data to create a histogram showing
%                    the frequency with which each label occurs.
%
%   RES = LABEL_FREQ_HIST(DATA1, {DATA2, ...})  
%   Each DATA item passed can either by a string giving the path and filename of
%   saved training data file (structured according to CREATE_TRAINING_DATA()),
%   or it can be a struct formatted according to the struct returned via
%   CREATE_TRAINING_DATA.  Counts of the number of occurences of each class
%   id found over all the DATA items are tallied, and the resulting histogram 
%   is plotted on screen.
%
%   If there is a problem at any point during file parsing or structure
%   creation, an appropriate error is returned to the caller.
%
%   REQUIRES:
%   PARSE_TRAINING_DATA
%   SET_XTICK_LABEL


% CVS INFO %
%%%%%%%%%%%%
% $Id: label_freq_hist.m,v 1.1 2006-01-18 22:51:05 scottl Exp $
% 
% REVISION HISTORY:
% $Log: label_freq_hist.m,v $
% Revision 1.1  2006-01-18 22:51:05  scottl
% Initial revision.
%
%


% LOCAL VARS %
%%%%%%%%%%%%%%
totals = [];  % this will hold our frequency counts


% first do some argument sanity checking on the argument passed
if nargin < 1
    error('At least one DATA item must be passed.');
end

% initialize our total counts using our first element to determine the number
% and order of the classes.  Note that this assumes that the class labels are
% ordered consecutively starting at 1, and that each subsequent data item
% uses the exact same ordering.  This is the case in our data, but could 
% conceivably change in the future so something more robust should ideally be
% used.
if ischar(data)
    data = parse_training_data(data);
end
totals = zeros(1,length(data.class_names));

% loop over each passed data element
alldata = [data, varargin];
for i = 1:length(alldata)

  %see if we have to load the data from a file (i.e. string passed)
  if ischar(alldata(i))
      D = parse_training_data(alldata(i));
  else
      D = alldata(i);
  end

  % go through each of the pages, adding counts to the totals
  for j = 1:D.num_pages
      for k=1:length(D.pg{j}.cid)
          totals(D.pg{j}.cid(k)) = totals(D.pg{j}.cid(k)) + 1;
      end
  end
end

% print the totals
fprintf('class total counts:\n');
disp(totals);
fprintf('\n\n');

fprintf('total number of regions: %d\n', sum(totals));

% now plot the histogram and label the axes
axis tight;
bar(totals)
title('Class Label Counts');
labels = char(data.class_names);
set_xtick_label(labels, 90, 'Class Names');


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
