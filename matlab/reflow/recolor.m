function pix = recolor(jt,fpath);

cols = label_colmap;

p = 1 - imread(jt.img_file);

indmap = zeros(size(p));
for i=1:length(jt.class_id);
    r = jt.rects(i,:);
    indmap(r(2):r(4),r(1):r(3))=label_col_ind(jt.class_name(jt.class_id(i)));
end;
indmap = 1 + (indmap .* p);
pix = ind2rgb(indmap,cols);

if (nargin >1);
    imwrite(pix,fpath);
end;

function cmap=label_colmap();
cmap = [1   1   1;    ... % 0=white (blank)
        0   0   0;    ... % 1=black
        0.1 0.1 0.1;  ... % 2=very dark gray
        0.2 0.2 0.2;  ... % 3=dark gray
        0.3 0.3 0.3;  ... % 4=gray
        0.4 0.4 0.4;  ... % 5=light grey
        0   0   0.8;  ... % 6=blue
        0   0   0.85; ... % 7
        0   0   0.9;  ... % 8
        0   0   0.95; ... % 9
        0   0   1;   ... % 10
        0   0.8 0;   ... % 11 Greens
        0   0.85 0;  ... % 12
        0   0.9 0;   ... % 13
        0   0.95 0;  ... % 14
        0   1   0;   ... % 15
        0.8 0   0;   ... % 16 Reds
        0.85 0  0;   ... % 17
        0.9 0   0;   ... % 18
        0.95 0  0;   ... % 19
        1   0   0;   ... % 20
        0.8 0.8 0;   ... % 21 Yellows
        0.9 0.7 0;   ... % 22
        1   1   0;   ... % 23
        0   1   1];      % 24 Cyan, for references

function ind=label_col_ind(cname);

switch (char(cname));
    %Text and variants
    case 'text'
        cind = 1;
    case 'abstract'
        cind = 2;
    case 'references'
        cind = 24;
    case 'footnote'
        cind = 3;
    case 'authour_list'
        cind = 4;
    case 'editor_list'
        cind = 4;
    case 'bullet_item'
        cind = 4;
    case 'toc' 
        cind = 4;
    case 'figure_caption'
        cind = 5;
    case 'figure_label'
        cind = 5;
    case 'table_label'
        cind = 5;
    case 'table_caption'
        cind = 5;

    %Headings
    case 'section_heading'
        cind = 6;
    case 'main_title'
        cind = 7;
    case 'subsection_heading'
        cind = 8;
    case 'footer'
        cind = 9;
    case 'header'
        cind = 10;
    
    %Figures and variants
    case 'figure'
        cind = 11;
    case 'code_block'
        cind = 12;
    case 'graph'
        cind = 13;
    case 'image'
        cind = 14;
    case 'table'
        cind = 15;
    
    %Equations and related
    case 'equation'
        cind = 16;
    case 'eq_number'
        cind = 17;
    
    %Decoration and related
    case 'decoration'
        cind = 21;
    case 'pg_number'
        cind = 22;
end;

ind = cind;
