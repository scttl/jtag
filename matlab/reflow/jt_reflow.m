function [pix,regs] = jt_reflow(jt, newwidth);

margin_top = 100;
margin_bottom = 100;
margin_right = 50;
margin_left = 50;
reg_spacing_v = 25;
reg_spacing_h = 20;

global class_names;

pix = imread(jt.img_file);

regs = prep_for_reflowing(jt,pix,newwidth);

y = 1;
i = 1;
while (i <= length(regs));
    if (~regs(i).takefullrow) && ...
       (i < length(regs)) && ...
       (~regs(i+1).takefullrow) && ...
       ((size(regs(i).pix,2)+size(regs(i+1).pix,2)+reg_spacing_h) <= newwidth);
        %merge them
        newregpix = ones(max(size(regs(i).pix,1),size(regs(i+1).pix,1)), ...
              (size(regs(i).pix,2) + size(regs(i+1).pix,2) + reg_spacing_h));
        newregpix(1:size(regs(i).pix,1),1:size(regs(i).pix,2)) = regs(i).pix;
        newregpix(1:size(regs(i+1).pix,1), ...
                  (end-size(regs(i+1).pix,2)+1):end) = regs(i+1).pix;
        regs(i).pix = newregpix;
        regs(i).cname = 'Figure';
        regs(i).keepwithnext = false;
        regs(i).takefullrow = false;
        regs(i+1) = [];
    else;
        newregpix = ones(size(regs(i).pix,1),newwidth);
        newregpix(1:size(regs(i).pix,1),1:size(regs(i).pix,2)) = regs(i).pix;
        regs(i).pix = newregpix;
        i = i+1;
    end;
end;

newpix = ones((margin_top+1 - reg_spacing_v),newwidth);
for i=1:length(regs);
    newpix = [newpix; ones(reg_spacing_v,newwidth); regs(i).pix];
end;
newpix = [newpix; ones(margin_bottom, newwidth)];
newpix = [ones(size(newpix,1),margin_left), ...
          newpix, ...
          ones(size(newpix,1),margin_right)];

pix = newpix;




%--------------------------------
%Subfunctions
function regs = prep_for_reflowing(jt,pix,newwidth);

useslope = 30;
rorderscores = jt.rects(:,1) + (30 * jt.rects(:,2));
[junk,rorder] = sort(rorderscores,1,'ascend');

for i=1:length(jt.class_id);
    s = rorder(i);
    r = jt.rects(s,:);
    cn = jt.class_name(jt.class_id(s));
    if (isTextRegion(cn) && ...
        ((jt.rects(s,3)-jt.rects(s,1)+1) > newwidth));
        regs(i).pix = reflow_region(pix, min(newwidth,(r(3)-r(1)+1)), ...
                                    jt.rects(s,:));
        regs(i).pix = regs(i).pix.ink;
        regs(i).cname = jt.class_name(jt.class_id(s));
    elseif ((jt.rects(s,3)-jt.rects(s,1)+1) > newwidth);
        resizefactor = (newwidth-1) / (r(3)-r(1)+1);
        oldpix = pix(r(2):r(4),r(1):r(3));
        regs(i).pix = imresize(oldpix,resizefactor);
        regs(i).cname = jt.class_name(jt.class_id(s));
    else;
        regs(i).pix = pix(r(2):r(4),r(1):r(3));
        regs(i).cname = jt.class_name(jt.class_id(s));
    end;
    
    if (strcmp(cn,'text'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'authour_list'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'section_heading'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'main_title'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'decoration'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'footnote'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'abstract'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'eq_number'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'equation'));
        regs(i).takefullrow = false;
        if ((i<length(jt.class_id)) && ...
           (strcmp('eq_number',jt.class_name(jt.class_id(rorder(i+1))))));
            regs(i).keepwithnext = true;
        else;
            regs(i).keepwithnext = false;
        end;
    elseif (strcmp(cn,'graph'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'table'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'table_caption'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'figure_caption'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'references'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'subsection_heading'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'image'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'bullet_item'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'code_block'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'figure'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'figure_label'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'table_label'));
        regs(i).takefullrow = false;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'header'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'editor_list'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'pg_number'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'footer'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'start_of_page'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    elseif (strcmp(cn,'end_of_page'));
        regs(i).takefullrow = true;
        regs(i).keepwithnext = false;
    end;
end;



function yn = isTextRegion(cn);
    global class_names;
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
        yn = false;
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
        yn = false;
    elseif (strcmp(cn,'editor_list'));
        yn = true;
    elseif (strcmp(cn,'pg_number'));
        yn = false;
    elseif (strcmp(cn,'footer'));
        yn = false;
    elseif (strcmp(cn,'start_of_page'));
        yn = false;
    elseif (strcmp(cn,'end_of_page'));
        yn = false;
    end;

