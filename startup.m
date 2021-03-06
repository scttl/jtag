addpath('./matlab/');
addpath('./matlab/logisticregression/');
addpath('./matlab/knn/');
addpath('./matlab/rgs/');
addpath('./matlab/segmentation/');
addpath('./matlab/learntocut/');
addpath('./matlab/ltc2/');
addpath('./matlab/ltc3/');
addpath('./matlab/features/');
addpath('./matlab/utils/');
addpath('./matlab/memm/');
addpath('./matlab/merge/');
addpath('./matlab/reflow/');
addpath('./matlab/candcut/');
addpath('./matlab/hmm/');
addpath('./matlab/gaussnb/');
global class_names
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
use.ocr = false;
