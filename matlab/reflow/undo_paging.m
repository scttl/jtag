function blocks = undo_paging(blocks,pix);
%
%function blocks = undo_paging(blocks,pix);
%
% Undoes the page-distribution-specific formatting details in blocks.
% This includes re-mergeing text regions that were split during the
% original page layout, 

i=1;
while i<length(blocks);
    endofthispage = true;
    textstartsnextpage = false;
    mergewith = 0;
    b1=blocks(i);
    %If this is a text region with a character in the bottom-right corner:
    if (strcmp(b1.cname,'text') && ...
       (min(min(b1.original_ink(end-8,end-10))) == 0));
        %Check if there are any more regions on this page that are not
        %decoration, footnote, footer, or page number.  Also, check if
        %the first region on the next page (other than header and page
        %number regions) is a text region.
        %fprintf('Found a text region with ink in the b/l corner.  ');
        for j=(i+1):length(blocks);
            b2 = blocks(j);
            if (b1.page_num == b2.page_num);
                if ~(strcmp(b2.cname, 'pg_number') || ...
                     strcmp(b2.cname, 'footnote') || ...
                     strcmp(b2.cname, 'decoration') || ...
                     strcmp(b2.cname, 'footer'));
                    endofthispage = false;
                    %fprintf('But a %s region came after it.\n',char(b2.cname));
                    break;
                end;
            elseif (b1.page_num+1 == b2.page_num);
                if ~(strcmp(b2.cname, 'pg_number') || ...
                     strcmp(b2.cname, 'header'));
                    if (strcmp(b2.cname, 'text'));
                        textstartsnextpage = true;
                        %fprintf('And the next page starts with text.\n');
                        mergewith = j;
                    else;
                        %fprintf('But the next page starts with non-text.\n');
                    end;
                    break;
                end;
            else;
                %fprintf('But this is the last page.\n');
                break;
            end;
        end;
    end;

    %If all conditions are met, merge the regions.
    if (endofthispage && textstartsnextpage && (mergewith ~= 0));
        %fprintf('Conditions are right: merging blocks.\n');
        rect=[min(b1.rect(1),b2.rect(1)),min(b1.rect(2),b2.rect(2)), ...
              max(b1.rect(3),b2.rect(3)),max(b1.rect(4),b2.rect(4))];
        words = [b1.words;b2.words];
        b1.rect = rect;
        b1.words = words;
        b1.original_ink = b2.original_ink;
        blocks(i) = b1;
        blocks(j) = [];
        i = i + 1;
    else;
        i = i + 1;
    end;
end;



