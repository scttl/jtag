function new_files = pre_ocr_article(art_name,out_name,showit);
%
%function new_files = pre_ocr_article(art_name,out_name,showit);
%
%Pre-processes the article specified by art_name for OCR, saving
%the new images to the location specified by out_name.
%
% art_name should
% be the full path of the article, but should not include the page
% number indicator, nor the extension.  For example, if an article
% contains 4 pages:
%     /jtag/Journals/nips2001/AA01.aa.jtag
%     /jtag/Journals/nips2001/AA01.ab.jtag
%     /jtag/Journals/nips2001/AA01.ac.jtag
%     /jtag/Journals/nips2001/AA01.ad.jtag
% Then article_name should be "/jtag/Journals/nips2001/AA01".
%
%
%out_name should be specified in a similar way.  For example, if
%the desired output files from the above example were:
%     /jtag/Journals/pre-ocr/nips2001/AA01.aa.jtag
%     /jtag/Journals/pre-ocr/nips2001/AA01.ab.jtag
%     /jtag/Journals/pre-ocr/nips2001/AA01.ac.jtag
%     /jtag/Journals/pre-ocr/nips2001/AA01.ad.jtag
% Then article_name should be "/jtag/Journals/pre-ocr/nips2001/AA01".

global article;

load_article(art_name,false);

new_files = [];

for i=1:length(article.page);
    jt = article.page{i};
    outpath = jt.img_file;
    dot_idx = regexp(outpath, '\.');
    if (length(dot_idx) > 1);
        outpath = [out_name outpath(dot_idx(end-1):end)];
    else;
        error('ERROR - improper format for article name.\n');
    end;
    [pix,img_file_paths] = pre_ocr_page(jt,outpath);
    if (showit);
        imshow(pix);
        pause;
    end;
    newfile.pagefile = outpath;
    newfile.subfiles = img_file_paths;
    new_files = [new_files; newfile];
end;





