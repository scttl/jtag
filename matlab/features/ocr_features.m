function res = ocr_features(use, rects, pixels)
% OCR_FEATURES   Subjects RECTS to a variety of OCR related features.
%
%  OCR_FEATURES(USE, RECT, PAGE, {THRESHOLD})  Runs the 4 element vector 
%  RECT passed against OCR features, each of which returns a
%  scalar value.  These values along with the feature name are built up as
%  fields in a struct, with one entry for each feature.  These entries are
%  combined in a cell array and returned as RES.
%

% LOCAL VARS %
%%%%%%%%%%%%%%

bg = 1;             % default value for background (white) pixels
                    % Black pixels have a value of 0.
get_names = false;  % determine if we are looking for names only

%If the OCR features are not being used, return an empty variable.
if (~isfield(use, 'ocr') || ~use.ocr);
    res = {};
    return;
end;

if nargin == 1
    get_names = true;  %This means only the feature names should be returned.
    rects = ones(1);
end;


%---------------------------------------------------
%Begin actual feature extraction here.

%First, the names:
for rr = 1:size(rects,1);
    fnum = 1;
    res(rr,fnum).name = '';    % A short name for the feature
    fnum = fnum + 1;           % Increment the feature number.
end;

if (get_names);  %If we only want the names, terminate now.
    return;
end;

%Finally, the feature values
for rr = 1:size(rects,1);
    rect = rects(rr,:);

    fnum = 1;

    res(rr,fnum).val = 0;      % Feature value
    res(rr,fnum).norm = false; % Whether the feature is pre-normalized.  Leaving
                            % this false for all features should be fine.
    fnum = fnum + 1;        % Increment the feature number.

end;
    
