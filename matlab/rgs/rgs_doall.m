function scores = rgs_doall();

diary ./results/rgs/rgs_diary.txt
diary on;

ntrn=parse_training_data('./results/2004-10-04/2004-10-04-nips-train.knn.mat');
ntrn=rgs_create_td(ntrn);
nparams=rgs_get_params(ntrn);

ntst=parse_training_data('./results/2004-10-04/2004-10-04-nips-test.knn.mat');
ntst=rgs_create_td(ntst);

scores.ntrn=dobatch(ntrn,nparams,'./results/rgs/nips-train-results.mat');
scores.ntst=dobatch(ntst,nparams,'./results/rgs/nips-test-results.mat');

jtrn=parse_training_data('./results/2004-10-04/2004-10-04-jmlr-train.knn.mat');
jtrn=rgs_create_td(jtrn);
jparams=rgs_get_params(jtrn);

jtst=parse_training_data('./results/2004-10-04/2004-10-04-jmlr-test.knn.mat');
jtst=rgs_create_td(jtst);

scores.jtrn=dobatch(jtrn,jparams,'./results/rgs/jmlr-train-results.mat');
scores.jtst=dobatch(jtst,jparams,'./results/rgs/jmlr-test-results.mat');

diary off;



function score = dobatch(td,params,outfile);

fprintf('Starting batch for %s.\n',outfile);

score = 0;

for i=1:length(td.pg_names);
    jt = jt_load(char(td.pg_names{i}),0);
    pix = imread(jt.img_file);
    [segs,pg_ll] = rgs_page(jt,params);
    pg(i).segs = segs;
    ll = seg_eval_2(pix,segs,jt.rects);
    score = score + ll;
    fprintf('Page %i of %i scored %i, for total %i.\n',i, ...
            length(td.pg_names),ll,score);
    evalstr = ['save ' outfile '-progress.mat pg score'];
    eval(evalstr);
end;

evalstr = ['save ' outfile ' pg score'];
eval(evalstr);
 
