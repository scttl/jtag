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
           '.  Press <- or -> to change pages, or "e" to edit in JTAG']);
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
    fprintf('lastChar = \n');
    disp(lastChar);
    if ((lastChar == char(28)) || (lastChar == char(30)) || ...
        (lastChar=='p') || (lastChar=='P') || (lastChar=='<'));
        pp;
    elseif ((lastChar == char(29)) || (lastChar == char(31)) || ...
            (lastChar=='n') || (lastChar=='N') || (lastChar=='>'));
        np;
    elseif (lastChar == 'e') || (lastChar == 'E');
        jt_edit;
    elseif (lastChar == 'c') || (lastChar == 'C');
        global class_names;
        global article;
        global use;
        olduse = use;
        use.dist = true; use.snap = false; use.dens = true; use.mark = false;
        jt = article.page{article.curpage};
        classify_pg(class_names, jt.img_file, 'lr_fn', ...
            '/h/40/klaven/jtag/matlab/results/nosnap/nosnap-jmlr-train.lr.mat');
        use = olduse;
        jt = jt_load(jt.jtag_file,0);
        article.page{article.curpage} = jt;
        page(article.curpage);
    end;
    

