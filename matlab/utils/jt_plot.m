function jt = jt_plot(jtpath, fighandle);
%
% function res = jt_plot(jtpath);
%
% Plots the tagged journal at jtpath.
%
% Inputs: jtpath is the file path of the .jtag file to be plotted
%
% Output: jt is a structure containing the jtag information of
%               the file at jtpath
%

if (nargin == 1);
    f = figure;
else
    f = fighandle;
end;

if (iscell(jtpath) || isstr(jtpath));
    jt = parse_jtag(jtpath);
else
    jt = jtpath;
end;

colours = zeros(3,length(jt.class_id));
for i = 1:length(jt.class_id);
    switch (jt.class_name{jt.class_id(i)});
        case 'code_block'
            colours(:,i) = [0.55;0;0];
        case 'abstract'
            colours(:,i) = [0.72;0;0];
        case 'references'
            colours(:,i) = [0.82;0;0];
        case 'inline_heading'
            colours(:,i) = [1;0;0];
        
        case 'section_heading'
            colours(:,i) = [0;0.35;0];
        case 'main_title'
            colours(:,i) = [0;0.7;0];
        case 'subsection_heading'
            colours(:,i) = [0;1;0];
        
        case 'authour_list'
            colours(:,i) = [0;0;0.6];
        case {'equation_no_number', 'equation_numbered'}
            colours(:,i) = [0;0;0.8];
        case 'bullet_item'
            colours(:,i) = [0;0;1];
        
        case 'editor_list'
            colours(:,i) = [0.5;0.5;0];
        case 'footer'
            colours(:,i) = [0.7;0.7;0];
        case 'header'
            colours(:,i) = [0.88;0.88;0];
            colours(:,i) = [1;0.5;0];
        case 'graph'
            colours(:,i) = [1;1;0];
        
        case 'toc' 
            colours(:,i) = [0.45;0;0.45];
        case 'figure_caption'
            colours(:,i) = [0.55;0;0.55];
        case 'decoration'
            colours(:,i) = [1;0;0.5];
        case 'figure_label'
            colours(:,i) = [1;0;1];
        
        case 'image'
            colours(:,i) = [0;0.4;0.4];
        case 'eq_number'
            colours(:,i) = [0;0.7;0.5];
        case 'text'
            colours(:,i) = [0;0.8;0.8];
        case 'pg_number'
            colours(:,i) = [0;1;1];
        
        case 'table_caption'
            colours(:,i) = [0;0;0];
        case 'footnote'
            colours(:,i) = [0.5;0.5;0.5];
            colours(:,i) = [1;0.6;0.6];
        case 'table'
            colours(:,i) = [0.7;0.7;0.7];
        case 'table_label'
            colours(:,i) = [0.9;0.9;0.9];

        otherwise
            colours(:,i) = [0.25;0.5;0.75];
    end;
end;

seg_plot(imread(jt.img_file),jt.rects,f,colours);


