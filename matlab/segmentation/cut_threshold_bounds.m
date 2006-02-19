function [hmins, hmaxs, vmins, vmaxs] = cut_threshold_bounds(data, varargin)
% CUT_THRESHOLD_BOUNDS    Iterates through each region of each page in each
%                    data element passed, to calculate the frequency of the
%                    cut threshold run-lengths.
%
%   [HMIN, HMAX, VMIN, VMAX] = CUT_THRESHOLD_BOUNDS(DATA1, {DATA2, ...})  
%   Each DATA item passed can either by a string giving the path and filename of
%   saved training data file (structured according to CREATE_TRAINING_DATA()),
%   or it can be a struct formatted according to the struct returned via
%   CREATE_TRAINING_DATA.  This function counts the largest run that wasn't
%   separated by a region to get a bound on the minimum threshold for that
%   page, and also counts the smallest run that was separated by a region on
%   the page, to get a bound on the maximum threshold for that page.
%   This is summed over all pages and all DATA items, and a histogram of the
%   counts is plotted on screen.
%
%   If there is a problem at any point during file parsing or structure
%   creation, an appropriate error is returned to the caller.
%
%   REQUIRES:
%   PARSE_TRAINING_DATA


% CVS INFO %
%%%%%%%%%%%%
% $Id: cut_threshold_bounds.m,v 1.1 2006-02-19 18:50:04 scottl Exp $
% 
% REVISION HISTORY:
% $Log: cut_threshold_bounds.m,v $
% Revision 1.1  2006-02-19 18:50:04  scottl
% Initial checkin
%


% LOCAL VARS %
%%%%%%%%%%%%%%
vmins = [];  % this will hold our vertical minimum threshold bounds (1 per page)
vmaxs = [];  % this will hold our vertical maximum threshold bounds (1 per page)
hmins = [];  % this will hold our horiz minimum threshold bounds (1 per page)
hmaxs = [];  % this will hold our horiz maximum threshold bounds (1 per page)
curr = 1;    % this indexes the current page being inspected.
img_extn = 'tif';  % the image extension to use
ignore_decorations = false;  %set this to true to avoid including decorations


% first do some argument sanity checking on the argument passed
if nargin < 1
    error('At least one DATA item must be passed.');
end

% loop over each passed data element
alldata = {data, varargin{:}};
for i = 1:length(alldata)

  %see if we have to load the data from a file (i.e. string passed)
  if ischar(alldata{i})
      D = parse_training_data(alldata{i});
  else
      D = alldata{i};
  end

  % go through each of the pages, adding counts to the totals
  for j = 1:D.num_pages
      % start with the upper bounds.  These can be taken from the rectangles
      % themselves, as the smallest rectangle cut defines a longest run.
      % find the minimium rectangle height taken.  Columns ordered L, T, R, B

      if ignore_decorations
          sels = D.pg{j}.cid ~= 5;
      else
          sels = ones(1,length(D.pg{j}.cid));
      end

      vmaxs(curr) = min(D.pg{j}.rects(sels,4) - D.pg{j}.rects(sels,2));
      % find the minimum rectangle width taken.
      hmaxs(curr) = min(D.pg{j}.rects(sels,3) - D.pg{j}.rects(sels,1));

      % each file is stored in the data with the extension .jtag
      % replace this with img_extn so we can operate on the pixel data
      base = D.pg_names{j}(1:end-4);
      file = strcat(base, img_extn);
      pix = 1 - imread(file);

      % sum the pixels horizontally, and determine the lengths of non-zero
      % runs (i.e ink runs since we've flipped the pixels to have 1 be 'on')
      % inside of region bounds.  The region bounds define our selected run
      % length thresholds, and so our smaller non-selected run thresholds lie
      % within these bounds.
      vmins(curr) = 0;
      hmins(curr) = 0;
      for r = 1:size(D.pg{j}.rects, 1)
          if ignore_decorations & D.pg{j}.cid(r) == 5
              continue;
          end
          hsum = sum(pix(D.pg{j}.rects(r,2):D.pg{j}.rects(r,4), ...
                         D.pg{j}.rects(r,1):D.pg{j}.rects(r,3)), 2);
          run_len = 0;
          for k = 1:length(hsum)
              if hsum(k) > 0 & k < length(hsum)
                  run_len = run_len + 1;
              else
                  if k == length(hsum)
                     run_len = run_len + 1;
                  end
                  if run_len > 0 & run_len > vmins(curr) & ...
                     run_len <= vmaxs(curr)
                      vmins(curr) = run_len;
                  end
                  run_len = 0;
              end
          end

          % repeat for the vertical case.
          vsum = sum(pix(D.pg{j}.rects(r,2):D.pg{j}.rects(r,4), ...
                         D.pg{j}.rects(r,1):D.pg{j}.rects(r,3)), 1);
          run_len = 0;
          for k=1:length(vsum)
              if vsum(k) > 0 & k < length(vsum)
                  run_len = run_len + 1;
              else
                  if k == length(vsum)
                      run_len = run_len + 1;
                  end
                  if run_len > 0 & run_len > hmins(curr) & ...
                     run_len <= hmaxs(curr)
                      hmins(curr) = run_len;
                  end
                  run_len = 0;
              end
          end
      end

      fprintf('next page\n');
      curr = curr + 1;
  end
end

% now plot the histogram and label the axes
%lets assume we want bins corresponding to the first 300 pixel values
Bins = [1:300];
V(:,1) = hist(vmins, Bins)';
V(:,2) = hist(vmaxs, Bins)';
V
subplot(2,1,1), bar(Bins,V);
title('Vertical');
legend('min', 'max');
axis([0, 305, 0, 80]);

HBins = [10:20:1500];
H(:,1) = hist(hmins, HBins)';
H(:,2) = hist(hmaxs, HBins)';
H
subplot(2,1,2), bar(HBins, H);
title('Horizontal');
legend('min', 'max');
axis ([0, 1300, 0, 150]);


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
