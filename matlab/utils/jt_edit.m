function jt = jt_edit;
    global article;
    global class_names;
    global use;

    jt = article.page{article.curpage};
    dump_jfiles(jt);
    cd ..;
    evalstr = ['!main.tcl ' jt.img_file];
    eval(evalstr);
    cd matlab;
    
    %olduse = use;
    %use.dist = true;
    %use.snap = false;
    %use.dens = true;
    %use.mark = false;
    %classify_pg(class_names, jt.img_file, 'lr_fn', ...
    %     '/h/40/klaven/jtag/matlab/results/nosnap/nosnap-jmlr-train.lr.mat');
    %use = olduse;
    pagetoload = article.curpage;
    close; close;
    load_article(article.name);
    page(pagetoload);
    %jt = jt_load(jt.jtag_file,0);
    %article.page{article.curpage} = jt;
    %page(article.curpage);
