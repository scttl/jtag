function words = get_words(pix,jt);

lines = get_text_lines(pix);

words = [];
for i=1:size(lines,1);
    l = lines(i,:);
    subpix = pix(l(2):l(4),l(1):l(3));
    lwords = xycut(subpix,6,10);
    [junk,wordorder] = sort(lwords(:,1));
    lwords(:,1) = lwords(wordorder,1) + l(1) - 1;
    lwords(:,3) = lwords(wordorder,3) + l(1) - 1;
    lwords(:,2) = l(2);
    lwords(:,4) = l(4);
    
    %vproj = mean(subpix);
    %word_open = false;
    %for j=1:length(vproj);
    %    if word_open;
    words = [words; lwords];
end;
            

