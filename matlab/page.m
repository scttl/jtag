function jt = page(pnum);
%
% function jt = page(pnum);
%
% Sets the current page in the display to page number pnum from the
% current article.
%
% Returns the jtag data structure for that page.
%

global article;

if (pnum <= length(article.page) && (pnum >= 1));
    f = article.fig_handle;
    if (~ishandle(f));
        f = figure('KeyPressFcn',@keyPressed);
        article.fig_handle = f;
    end;
    %a = get(article.fig_handle,'CurrentAxes');
    jt = jt_plot(article.page{pnum}, article.fig_handle);
    set(f,'Name',article.page{pnum}.jtag_file);
    set(f,'NumberTitle','off');
    title(['Page ' int2str(pnum) ' of ' int2str(length(article.page)) ...
           '.  Press <- or -> to change pages']);
    article.curpage = pnum;
else
    fprintf('Page %i does not exist.\n',pnum);
    beep;
    jt = article.page{article.curpage};
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function keyPressed(obj,eventdata);
    lastChar = get(obj,'CurrentCharacter');
    if ((lastChar == char(28)) || (lastChar == char(30)) || ...
        (lastChar=='p') || (lastChar=='P') || (lastChar=='<'));
        pp;
    elseif ((lastChar == char(29)) || (lastChar == char(31)) || ...
            (lastChar=='n') || (lastChar=='N') || (lastChar=='>'));
        np;
    end;
    
