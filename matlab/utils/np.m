function jt = np;
%
% function jt = np;
%
% Brings up the Next Page in the display.  Returns the JTAG information
% for that page.
%

global article;

if (article.curpage < length(article.page));
    jt = page(article.curpage + 1);
else
    %fprintf('Last page.\n');
    beep;
    jt = article.page{article.curpage};
end;



