function jtags = pages_to_jtag(pages, jt_file_base, saveit, colortoo);

if (nargin < 3);
    saveit = true;
end;
if (nargin < 4);
    colortoo = false;
end;

global class_names;

jtags = [];
for i=1:length(pages);
    pg = pages(i);
    clear jt;
    jt.img_file = [jt_file_base '.' ind_to_letters(i) '.tif'];
    jt.jtag_file = [jt_file_base '.' ind_to_letters(i) '.jtag'];
    jt.jlog_file = [jt_file_base '.' ind_to_letters(i) '.jlog'];
    jt.class_name = class_names;
    jt.rects = [];
    jt.class_id = [];
    for j=1:length(pg.blocks);
        b = pg.blocks(j);
        jt.rects = [jt.rects;b.rect];
        jt.class_id = [jt.class_id;get_cid(char(b.cname))];
    end;
    if (saveit);
        imwrite((pg.pix > 0), jt.img_file);
        dump_jfiles(jt);
        if (colortoo);
            recolor(jt,[jt_file_base '.' ind_to_letters(i) '-color.tif']);
        end;
    end;
    jtags = [jtags;jt];
end;


function res = ind_to_letters(ind);
    c1 = mod((ind-1), 26) + 1;
    c2 = floor((ind-1) / 26) + 1;
    res = [char(96 + c2) char(96 + c1)];
    
    
