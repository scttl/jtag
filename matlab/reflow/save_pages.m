function res = save_pages(pages,fpath,colortoo);;

for i=1:length(pages);
    imwrite((pages(i).pix > 0), [fpath '-p' int2str(i) '.tif']);
end;

if (nargin >= 3) && colortoo;
    jts = pages_to_jtag(pages);
    for i=1:length(jts);
        recolor(jts(i), [fpath '-color-p' int2str(i) '.tif']);
    end;
end;

res = 0;
