function res = ocr_features(use, rects, pixels, ocr, work_dir)
% OCR_FEATURES   Subjects RECTS to a variety of OCR related features.
%
%  OCR_FEATURES(USE, RECT, PIXELS, WORK_DIR)  Runs the 4 element vector 
%  RECT passed against OCR features, each of which returns a
%  scalar value.  These values along with the feature name are built up as
%  fields in a struct, with one entry for each feature.  These entries are
%  combined in a cell array and returned as RES.
%  OCR is a string name of the OCR application used.
%  WORK_DIR is a temporary directory to store subimages.

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% runs ocr on each subimage

%% get the number of rectangles
num_rects = size(rects, 1);

%% a list that stores ocr files for each rectangle
ocr_rects = cell(num_rects, 1);

for i = 1:num_rects;

    %% retrieve the ith rectangle
    rect = rects(i,:);
    %% extract the subimage
    subimg = pixels(rects(i,2):rects(i,4), rects(i,1):rects(i,3));
    %% write the subimage in the work directory
    img_path = sprintf('%s %s %s', work_dir, '/sub_image.', 'pbm');
    imwrite(subimg, img_path);

    %% run ocr on the image associated with the rectangle
    command = sprintf('%s %s', ocr, img_path);
    [status, ocr_text] = system(command);
    %% add the ocr file to the list
    ocr_rects{i} = ocr_text;

    %% clean up the work directory
    command = sprintf('rm -f %s', img_path);

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Begin actual feature extraction here.

%% First, the names:
for i = 1:size(rects,1);
    fnum = 1;

    %% A short name for the feature
    res(i,fnum).name = 'word_count';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_count';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'text_is_a_dash';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'text_is_a_star';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_matches_with_(PICTURE)';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'starts_with_table';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'starts_with_figure';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'starts_with_[number]';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_dots_in the_first_wrod';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_colons_in the_first_wrod';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_math_and_logic_symbols';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_double_quotes';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_single_quotes';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_matches_with_vol.';         
    %% Increment the feature number
    fnum = fnum + 1;                         

    %% A short name for the feature
    res(i,fnum).name = 'number_of_matches_with_pp.';         
    %% Increment the feature number
    fnum = fnum + 1;                         


end;

%% If we only want the names, terminate now
if (get_names);  
    return;
end;

%% Finally, the feature values
for i = 1:num_rects;

    %% retrieve the ith ocr text
    ocr_text = rects(i,:);

    fnum = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Total word count 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Feature value
    pat = '(.*?)\w+(.*?)';
    [s, f] = regexp(ocr_text, pat);
    word_count = size(s, 2);
    res(i,fnum).val = word_count;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Total number count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Feature value
    pat = '(.*?)\d+(.*?)';
    [s, f] = regexp(ocr_text, pat);
    number_count = size(s, 2);
    res(i,fnum).val = number_count;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% If the text is the sigleton '-'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Feature value
    res(i,fnum).val = strcmp(text, '-');      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% If the text is the singleton '*'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Feature value
    res(i,fnum).val = strcmp(text, '*');      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of the matches '(PICTURE)'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Feature value
    pat = '\(PICTURE\)';
    [s, f] = regexp(ocr_text, pat);
    count = size(s, 2);
    res(i,fnum).val = count;      


    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Text starts with 'Table'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% extract the first word
    pat = '(.*?)\w+(.*?)';
    [s, f] = regexp(ocr_text, pat, 'once');
    word = ' ';
    for i = s(1):f(1);
      if(~isspace(ocr_text(i)))
         word = strcat(word, ocr_text(i));
      end;
    end;

    distance_measure = 'levenshtein.perl'
    command = sprintf('%s %s table', distance_measure, lower(word));
    distance = system(command);

    %% Feature value
    res(i,fnum).val = distance;

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Text starts with 'Figure'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    command = sprintf('%s %s figure', distance_measure, lower(word));
    distance = system(command);

    %% Feature value
    res(i,fnum).val = distance;

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Text starts with '[number]'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    pat = '\[\d+\]';
    [s, f] = regexp(word, pat);
    count = size(s, 2);
    %% Feature value
    res(i,fnum).val = count;

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of '.' in the first segment of the text (~ first word)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = '\.';
    [s, f] = regexp(word, pat);
    count = size(s, 2);
     %% Feature value
    res(i,fnum).val = count;

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of ':' in the first segment of the text (~ first word)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = ':';
    [s, f] = regexp(word, pat);
    count = size(s, 2);
     %% Feature value
    res(i,fnum).val = count;

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of mathematical and logical operations, and symbols in the text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = ':|\*|\+|-|/|%|_|\$|\^|\(|\)|\\|\[|\]|\{|\}|=|!|\||&';
    [s, f] = regexp(ocr_text, pat);
    count = size(s, 2);
    %% Feature value
    res(i,fnum).val = 0;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of double quotes in the text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = '"';
    [s, f] = regexp(ocr_text, pat);
    count = size(s, 2);
    %% Feature value
    res(i,fnum).val = count;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;  

       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of ' in the text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = '''';
    [s, f] = regexp(ocr_text, pat);
    count = size(s, 2);
    %% Feature value
    res(i,fnum).val = count;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;  

       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of matches with 'vol.'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = 'vol.';
    [s, f] = regexp(lower(ocr_text), pat);
    count = size(s, 2);
    %% Feature value
    res(i,fnum).val = count;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;  

       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Number of matches with 'pp.'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pat = 'pp.';
    [s, f] = regexp(lower(ocr_text), pat);
    count = size(s, 2);
    %% Feature value
    res(i,fnum).val = 0;      

    %% Whether the feature is pre-normalized. Leaving
    %% this false for all features should be fine.
    res(i,fnum).norm = false; 

    %% Increment the feature number.
    fnum = fnum + 1;  

       


end;
