function [segs,score] = rgs_page(jt,rgs_params,start_seg);

max_rec = 2;


if (ischar(jt));
    jt = jt_load(jt);
end;
pix = imread(jt.img_file);

if (ischar(rgs_params));
    evalstr = ['load ' rgs_params];
    eval(evalstr);
    rgs_params = savedweightvar;
end;

if (nargin >2);
    startseg = start_seg;
else;
    startseg = [1,1,size(pix,2),size(pix,1)];
    startseg = seg_snap(pix,startseg);
end;

%First, check for "obvious cuts" - cuts where the valley is so big that
%it is unquestionably a cut.
segs = xycut(jt.img_file,60,30);
%fprintf('In %s, found %i segs using obvious cuts.\n',jt.img_file,size(segs,1));

allsegs = [];
score = 0;
for i=1:size(segs,1);
    [sg,sc] = rgs(pix,segs(i,:),rgs_params,1,jt.img_file,0,max_rec);
    %fprintf('Block %i has %i rects, sc=%i, score=%i.\n',i,size(sg,1),sc,score);
    allsegs = [allsegs;sg];
    score = score + sc;
end;
segs = allsegs;



function [segs,score] = rgs(pix,seg_in,rgs_params,h,img_path,rec_lev,max_rec);

scoremat = [];

score_in = rgs_eval(pix,seg_in,rgs_params,h,img_path);
if (rec_lev == max_rec);
    segs = seg_in;
    score = score_in;
    return;
end;
cuts = get_cut_cands(pix,seg_in,h);
[subsegs,cuts] = cuts_to_segs(seg_in,cuts,pix,h,0); %This pads cuts as well
numsubsegs = size(subsegs.rects,1);
%fprintf('Entering rgs.  numsubsegs = %i, subsegs = \n', numsubsegs);
%disp(subsegs);
if (numsubsegs > 0);
    %fprintf('We have %i subsegs from %i cuts',numsubsegs, length(cuts));
    %disp(subsegs);
    %fprintf('cut_before:\n');
    %disp(subsegs.cut_before);
    %fprintf('cut_after:\n');
    %disp(subsegs.cut_after);
    scoremat = zeros(length(cuts));
end;
for i = 1:numsubsegs;
    %fprintf('Recursion_level=%i, seg %i of %i\n',rec_lev,i,numsubsegs);
    c1 = subsegs.cut_before(i);
    c2 = subsegs.cut_after(i);
    if (c1 ~= 1) || (c2 < numsubsegs);
        [tmp1,tmp2] = rgs(pix,subsegs.rects(i,:),rgs_params,~h, ...
                          img_path,rec_lev+1,max_rec);
        %fprintf('Emerged from recursion on %i,%i.  tmp1=\n',c1,c2);
        %disp(tmp1);
        %fprintf('tmp2=\n');
        %disp(tmp2);
        scoremat(c1,c2) = tmp2;
        segmat(c1,c2).segs = tmp1;
    else; %Don't re-call rgs on the same seg (this prevents infinite
          %recursion.
        %fprintf('Not re-recursive on orig seg %i,%i.  score_in=\n',c1,c2);
        %disp(score_in);
        %fprintf('seg_in=\n');
        %disp(seg_in);
        scoremat(c1,c2) = score_in;
        segmat(c1,c2).segs = seg_in;
    end;
end;

if numsubsegs > 0; 
    %fprintf('Constructing best path with %i subsegs.  Scoremat = \n', ...
    %        numsubsegs);
    %disp(scoremat);
    if (rec_lev ==0);
        global gscoremat;
        global gsegmat;
        gscoremat = scoremat;
        gsegmat = segmat;
        global gsubsegs;
        gsubsegs = subsegs;
    end;
    [path,pathscore] = best_path(scoremat);
    
    segs = [];
    score = 0;
    for i=2:length(path);
        segs = [segs;segmat(path(i-1),path(i)).segs];
        score = score + scoremat(path(i-1),path(i));
    end;
    if (score ~= pathscore);
        fprintf('ERROR: score=%f, pathscore=%f\n',score,pathscore);
    end;
else;
    %fprintf('No subsegs available. score_in=\n');
    %disp(score_in);
    %fprintf('seg_in=\n');
    %disp(seg_in);
    segs = seg_in;
    score = score_in;
end;




function score = rgs_eval(pix,seg,rgs_params,h,img_path);

global rgs_eval_count;
rgs_eval_count = rgs_eval_count + 1;

global segs_considered;
segs_considered = [segs_considered; seg];

if (size(seg,1) > 1);
    fprintf('ERROR in rgs_eval: more than 1 seg passed.\n');
end;

features = rgs_get_features(pix,seg,img_path);
lls = rgs_region_ll(features.vals,rgs_params);
score = max(lls);
if (length(score) > 1);
    error('ERROR in rgs_eval in rgs_page.m\n');
end;


%global class_names;
%for i=1:length(class_names);
%    ll(i)=
%    
%    features = rgs_get_features(pix,seg,img_path);
%    feats = features.values;
%    means = rgs_params.means(i,:);
%    sigma = rgs_params.variance(i);
%    pix_on = sum(sum(1-pix(seg(2):seg(4),seg(1):seg(3))));
%    pix_off = sum(sum(pix(seg(2):seg(4),seg(1):seg(3))));
%    ll(i) = log(rgs_params.class_priors(i)) - ...
%            sum(log(sqrt(2 * pi * sigma))) + ...
%            sum((feats - means)^2 ./ (2*(sigma)^2)) + ...
%            pix_on * log(rgs_params.pix_on_frac(i)) + ...
%            pix_off * log(1-rgs_params.pix_on_frac(i));
%    
%end;    
%    
%score = max(ll);
%


