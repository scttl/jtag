function jt = pp;
%
% function jt = pp;
%
% Brings up the Previous Page in the display.  Returns the JTAG information
% for that page.
%

global article;

if (article.curpage > 1) 
    jt = page(article.curpage - 1);
else
    %fprintf('First page.\n');
    beep;
    jt = article.page{article.curpage};
end;


