function segs = voronoi1(pix,Td1,Td2);
%tic;
if (nargin < 2);
    Td1 = 8;
end;
if (nargin < 3);
    Td2 = 3;
end;

%mark_rects = smear(pix,1,1,0,1);
[L,num] = bwlabel(1-pix);
%fprintf('Call to bwlabel done at %i\n',toc);
mark_rects = [];
for i=1:num;
    L = sparse(L);
    [y,x] = find(L==i);
    rect=[min(x),min(y),max(x),max(y)];
    mark_rects = [mark_rects;rect];
end;
%fprintf('mark_rects found at %i\n',toc);

%Create the region map:
regmap = zeros(size(pix));
for i=1:size(mark_rects,1);
    regmap(mark_rects(i,2):mark_rects(i,4),mark_rects(i,1):mark_rects(i,3)) = i;
end;
%fprintf('regmap made at %i\n',toc);

%Find neighbours:
marks = [];
m1 = [];
m2 = [];
for i=1:size(mark_rects,1);
    mark = [];
    mark.id = i;
    rect = mark_rects(i,:);
    mark.rect = rect;
    l=rect(1); r=rect(3);
    t=rect(2); b=rect(4);
    %Find bottom neighbour(s)
    bn = [];
    for j=(b+1):size(pix,1);
        if (max(regmap(j,l:r)) > 0);
            bn = unique(regmap(j,l:r));
            bn = bn(find(bn>0));
            bn = reshape(bn,length(bn),1);
            break;
        end;
    end;

    %Find top neighbour(s)
    tn = [];
    for j=(t-1):-1:1;
        if (max(regmap(j,l:r)) > 0);
            tn = sort(unique(regmap(j,l:r)));
            tn = tn(find(tn>0));
            tn = reshape(tn,length(tn),1);
            break;
        end;
    end;

    %Find left neighbour(s)
    ln = [];
    for j=(l-1):-1:1;
        if (max(regmap(t:b,j)) > 0);
            ln = sort(unique(regmap(t:b,j)));
            ln = ln(find(ln>0));
            ln = reshape(ln,length(ln),1);
            break;
        end;
    end;

    %Find right neighbour(s)
    rn = [];
    for j=(r+1):size(pix,2);
        if (max(regmap(t:b,j)) > 0);
            rn = sort(unique(regmap(t:b,j)));
            rn = rn(find(rn>0));
            rn = reshape(rn,length(rn),1);
            break;
        end;
    end;
    mark.all_n = [tn;bn;ln;rn];
    for j=1:length(mark.all_n);
        m1 = [m1;i];
        m2 = [m2;mark.all_n(j)];
    end;
    marks = [marks;mark];
end;
%fprintf('neighbours found at %i\n',toc);

tmp1 = max([m1';m2']);
tmp2 = min([m1';m2']);
m1 = tmp1;
m2 = tmp2;
[junk,morder] = sort((100000*m1)+ m2);
m1 = m1(morder);
m2 = m2(morder);
i=2;
while (i <= length(m1));
    if (m2(i-1)==m2(i)) && (m1(i-1)==m1(i));
        m1(i) = [];
        m2(i) = [];
    else;
        i=i+1;
    end;
end;
m1 = reshape(m1,length(m1),1);
m2 = reshape(m2,length(m2),1);
%fprintf('Duplicate pairings (%i) removed at %i\n',(length(tmp1)-length(m1)), ...
%        toc);

%xy = [floor((mark_rects(:,1)+mark_rects(:,3))/2), ...
%      floor((mark_rects(:,2)+mark_rects(:,4))/2)];
%gplot(nmat,xy, 'r');
%drawnow;


%Compare each set of neighbours, and decide whether to merge them.
%mmat = false(size(marks));
%fprintf('About to check %i neighbours.\n', length(m1));
i = 1;
while i <= length(m1);
    %fprintf('Comparing %i of %i\n', i, length(m1));
    %fprintf('Comparing %i of %i: %i [%i %i %i %i] and %i [%i %i %i %i].\n', ...
    %        i, length(m1), ...
    %        m1(i), marks(m1(i)).rect(1), marks(m1(i)).rect(2), ...
    %               marks(m1(i)).rect(3), marks(m1(i)).rect(4), ...
    %        m2(i), marks(m2(i)).rect(1), marks(m2(i)).rect(2), ...
    %               marks(m2(i)).rect(3), marks(m2(i)).rect(4));
    if (should_merge_voronoi(marks(m1(i)),marks(m2(i)),pix,Td1,Td2));
        i = i+1;
        %mmat(m1(i),m2(i)) = true;
        %mmat(m2(i),m1(i)) = true;
    %    fprintf('    Merging\n');
    else;
        %fprintf('    NOT merging\n');
        m1(i) = [];
        m2(i) = [];
    end;
end;
%Now put this info back into the marks list
for i=1:size(marks,1);
    marks(i).all_n = m1(find(m2==i));
    marks(i).all_n = [marks(i).all_n;m2(find(m1==i))];
    %marks(i).all_n = find(mmat(i,:));
    %marks(i).all_n = reshape(marks(i).all_n,length(marks(i).all_n),1);
end;
%fprintf('Voronoi decisions done at %i\n',toc);

%xy = [floor((mark_rects(:,1)+mark_rects(:,3))/2), ...
%      floor((mark_rects(:,2)+mark_rects(:,4))/2)];
%gplot(mmat,xy,'b');
%drawnow;

%Start a record of which group each original group is currently in
find_mark = 1:length(marks);

%fprintf('Doing merges.\n');
m_groups = [];
todo = 1:length(marks);
while length(todo) > 0;
    %fprintf('%i merges left to do.\n',length(todo));
    m1 = marks(todo(1));
    todo(1) = [];
    while ((length(m1.all_n) > 0) && (length(todo) > 0));
        tmp = m1.all_n(1);
        m1.all_n(1) = [];
        if (length(find(todo == tmp)) > 0); %If this one isn't done yet
            m2 = marks(tmp);
            todo(find(todo == tmp)) = [];   %Remove that from todo
            m1 = merge_marks(m1,m2);
        end;
    end;
    m_groups = [m_groups;m1];
end;
%fprintf('Mergings done at %i\n',toc);

segs = [];
for i=1:length(m_groups);
    segs = [segs;m_groups(i).rect];
end;

segs = seg_snap(pix,segs);
segs = rem_overlapping_segs(pix,segs);

%fprintf('Finished at %i\n',toc);

%--------------------------------------------------------------------
%----Subfunction declarations


%[Td1,Td2] = voronoi_find_params(pix,mark_rects,nmat);
%dists = [];
%for i=1:




function yn = should_merge_voronoi(m1,m2,pix,Td1,Td2);
Ta = 40;

rdist = rect_dist(m1.rect,m2.rect,'ink',pix);

area1 = ((m1.rect(3)-m1.rect(1)+1) * (m1.rect(4)-m1.rect(2)+1));
area2 = ((m2.rect(3)-m2.rect(1)+1) * (m2.rect(4)-m2.rect(2)+1));
area_ratio = max(area1,area2) / min(area1,area2);
%fprintf('[%i %i %i %i], [%i %i %i %i]: ', ...
%        m1.rect(1), m1.rect(2), ...
%        m1.rect(3), m1.rect(4), ...
%        m2.rect(1), m2.rect(2), ...
%        m2.rect(3), m2.rect(4));

%fprintf('Dist=%i, area_ratio=%i, merge=',rdist,area_ratio);

if ((rdist/Td1) < 1) || ...
   (((rdist/Td2)+(area_ratio/Ta)) < 1);
    yn = true;
    %fprintf('true\n');
else;
    yn = false;
    %fprintf('false\n');
end;



function m_new = merge_marks(m1,m2);

    m_new.rect = [min(m1.rect(1),m2.rect(1)), min(m1.rect(2),m2.rect(2)), ...
                  max(m1.rect(3),m2.rect(3)), max(m1.rect(4),m2.rect(4))];
    m_new.all_n = [m1.all_n; m2.all_n];
    m_new.all_n = m_new.all_n(find(and((m_new.all_n~=m1.id), ...
                                       (m_new.all_n~=m2.id))));
    m_new_all_n = reshape(m_new.all_n,length(m_new.all_n),1);
    m_new.id = m1.id;
    
    

