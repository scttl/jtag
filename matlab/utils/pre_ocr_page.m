function [pix,image_files] = pre_ocr_page(jt,out_file);
%
%function [pix,image_files] = pre_ocr_page(jt,out_file);
%
%This function applies an OCR pre-processor to the page jt, saving the
%remaining text to out_file, with image names created by appending to
%the name of out_file.  For example, if out_file were AA03.aa.tif, an
%image file named AA03.aa.tif-figure1.jpg may be created.
%

if (ischar(jt));
    jt = jt_load(jt);
end;
dot_idx = regexp(out_file, '\.');
slash_idx = regexp(out_file, '/');
out_file_path = out_file(1:slash_idx(end));
out_file_name = out_file(slash_idx(end)+1:dot_idx(end)-1);
out_file_ext = out_file(dot_idx(end):end);

text_file = out_file;
image_files = [];

%Image file type categories
img_file_types = {'figure','table','equation','decoration'};
img_file_counts = [1,1,1,1];

pix = imread(jt.img_file);

%For each region
for i=1:size(jt.rects,1);
    r = jt.rects(i,:);
    cname = jt.class_name(jt.class_id(i));
    cid = get_cid(cname);
    %If it is not text, create a file name based on it's class, and save it.
    if (~is_ocr_text(cname));
        subpix = pix(r(2):r(4),r(1):r(3));
        typeid = image_type(cname);
        impath=[out_file_path out_file_name '-' img_file_types{typeid} '-' ...
                int2str(img_file_counts(typeid)) '.tif'];

        imwrite(subpix,impath);
        image_files = [image_files,impath];
        %Create an image of text referring viewers to the image.
        command = ['pbmtext "See ' out_file_name '-' img_file_types{typeid} ...
                   '-' int2str(img_file_counts(typeid)) '.tif" > ' ...
                   'jt_tmp_bitmap.bmp'];
        system(command);

        msg_pix = imread('jt_tmp_bitmap.bmp');
        subpix = ones(size(subpix));
        bottom = min(size(msg_pix,1),size(subpix,1));
        right = min(size(msg_pix,2),size(subpix,2));
        subpix(1:bottom,1:right) = msg_pix(1:bottom,1:right);
        img_file_counts(typeid) = img_file_counts(typeid) + 1;
        pix(r(2):r(4),r(1):r(3)) = subpix;
    else;   
        %If it is a text region, leave it for the OCR program
    end;
end;
imwrite(pix,out_file);



function res = image_type(cn);
%img_file_types = {'figure','table','equation','decoration'};

    if (strcmp(cn,'text'));
        res = 0;
    elseif (strcmp(cn,'authour_list'));
        res = 0;
    elseif (strcmp(cn,'section_heading'));
        res = 0;
    elseif (strcmp(cn,'main_title'));
        res = 0;
    elseif (strcmp(cn,'decoration'));
        res = 4;
    elseif (strcmp(cn,'footnote'));
        res = 0;
    elseif (strcmp(cn,'abstract'));
        res = 0;
    elseif (strcmp(cn,'eq_number'));
        res = 0;
    elseif (strcmp(cn,'equation'));
        res = 3;
    elseif (strcmp(cn,'graph'));
        res = 1;
    elseif (strcmp(cn,'table'));
        res = 2;
    elseif (strcmp(cn,'table_caption'));
        res = 0;
    elseif (strcmp(cn,'figure_caption'));
        res = 0;
    elseif (strcmp(cn,'references'));
        res = 0;
    elseif (strcmp(cn,'subsection_heading'));
        res = 0;
    elseif (strcmp(cn,'image'));
        res = 1;
    elseif (strcmp(cn,'bullet_item'));
        res = 0;
    elseif (strcmp(cn,'code_block'));
        res = 1;
    elseif (strcmp(cn,'figure'));
        res = 1;
    elseif (strcmp(cn,'figure_label'));
        res = 0;
    elseif (strcmp(cn,'table_label'));
        res = 0;
    elseif (strcmp(cn,'header'));
        res = 0;
    elseif (strcmp(cn,'editor_list'));
        res = 0;
    elseif (strcmp(cn,'pg_number'));
        res = 0;
    elseif (strcmp(cn,'footer'));
        res = 0;
    elseif (strcmp(cn,'start_of_page'));
        res = 4;
    elseif (strcmp(cn,'end_of_page'));
        res = 4;
    else;
        res = false;
    end;




function yn = is_ocr_text(cn);
    if (strcmp(cn,'text'));
        yn = true;
    elseif (strcmp(cn,'authour_list'));
        yn = true;
    elseif (strcmp(cn,'section_heading'));
        yn = true;
    elseif (strcmp(cn,'main_title'));
        yn = true;
    elseif (strcmp(cn,'decoration'));
        yn = false;
    elseif (strcmp(cn,'footnote'));
        yn = true;
    elseif (strcmp(cn,'abstract'));
        yn = true;
    elseif (strcmp(cn,'eq_number'));
        yn = true;
    elseif (strcmp(cn,'equation'));
        yn = false;
    elseif (strcmp(cn,'graph'));
        yn = false;
    elseif (strcmp(cn,'table'));
        yn = false;
    elseif (strcmp(cn,'table_caption'));
        yn = true;
    elseif (strcmp(cn,'figure_caption'));
        yn = true;
    elseif (strcmp(cn,'references'));
        yn = true;
    elseif (strcmp(cn,'subsection_heading'));
        yn = true;
    elseif (strcmp(cn,'image'));
        yn = false;
    elseif (strcmp(cn,'bullet_item'));
        yn = true;
    elseif (strcmp(cn,'code_block'));
        yn = false;
    elseif (strcmp(cn,'figure'));
        yn = false;
    elseif (strcmp(cn,'figure_label'));
        yn = true;
    elseif (strcmp(cn,'table_label'));
        yn = true;
    elseif (strcmp(cn,'header'));
        yn = true;
    elseif (strcmp(cn,'editor_list'));
        yn = true;
    elseif (strcmp(cn,'pg_number'));
        yn = true;
    elseif (strcmp(cn,'footer'));
        yn = true;
    elseif (strcmp(cn,'start_of_page'));
        yn = false;
    elseif (strcmp(cn,'end_of_page'));
        yn = false;
    else;
        yn = false;
    end;


