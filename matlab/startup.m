addpath('./logisticregression/');
addpath('./knn/');
addpath('./segmentation/');
addpath('./learntocut/');
addpath('./ltc2/');
addpath('./features/');
addpath('./utils/');
addpath('./memm/');
addpath('./reflow/');
global class_names;
class_names = {'text' 'authour_list' 'section_heading' 'main_title' ...
               'decoration' 'footnote' 'abstract' 'eq_number' ...
               'equation' 'graph' 'table' 'table_caption' ...
               'figure_caption' 'references' 'subsection_heading' ...
               'image' 'bullet_item' 'code_block' 'figure' ...
               'figure_label' 'table_label' 'header' 'editor_list' ...
               'pg_number' 'footer' 'start_of_page' 'end_of_page' };
global use;
use.dist = true;
use.snap = false;
use.pnum = true;
use.dens = true;
use.mark = true;


% imfile = 'cancedda03a.ac.tif';
% p = imread(imfile);

% segs = xycut(imfile);

