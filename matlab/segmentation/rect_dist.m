%Finds the minimum distance between any two points in r1 and r2
function [dist,v_dist,h_dist] = rect_dist(r1,r2,disttype,pix);
%
%function [dist,v_dist,h_dist] = rect_dist(r1,r2,disttype,pix);
%
% If disttype is omitted, or 'rect', uses the distance between
% the rectangles.  In this case, "pix" is not required.
%
% If disttype is 'ink', gives the minimum ditance between two
% marks of ink in the two marks.
%
if (nargin < 3) || strcmp(disttype, 'rect');
    if (r1(2) > r2(4));         %r2 is vertically before r1
        v_dist = r1(2) - r2(4);
    elseif (r2(2) > r1(4));     %r1 is vertically before r2
        v_dist = r2(2) - r1(4);
    else;                       %r1 and r2 meet vertically.
        v_dist = 0;
    end;

    if (r1(1) > r2(3));         %r2 is horizontally before r1
        h_dist = r1(1) - r2(3);
    elseif (r2(1) > r1(3));     %r1 is horizontally before r2
        h_dist = r2(1) - r1(3);
    else;                       %r1 and r2 meet horizontally
        h_dist = 0;
    end;

    dist = sqrt((h_dist^2) + (v_dist^2));

elseif strcmp(disttype, 'ink');

    p1 = pix(r1(2):r1(4),r1(1):r1(3));
    p2 = pix(r2(2):r2(4),r2(1):r2(3));

    %Find the "edge" pixels for each rect
    edges1 = edge_coords(r1,pix);
    edges2 = edge_coords(r2,pix);

    dist = inf;
    for i=1:size(edges1,1);
        tmp = repmat(edges1(i,:),size(edges2,1),1);
        tmp = tmp - edges2;
        tmp = tmp .* tmp;
        tmp2 = tmp(:,1) + tmp(:,2);
        tmp2 = sqrt(tmp2);
        [d,m_ind] = min(tmp2);
        if (d < dist);
            dist = d;
            v_dist = sqrt(tmp(m_ind,2));
            h_dist = sqrt(tmp(m_ind,1));
        end;
    end;
end;



function edges = edge_coords(r,pix);
    edges = [];
    for i = r(1):r(3);
        subpix = pix(r(2):r(4),i);
        ink = find((1-subpix)>0);
        if (length(ink) > 0);
            ink = r(2) - 1 + ink;
            edges = [edges;i,ink(1)];
        end;
        if (length(ink) > 1);
            edges = [edges;i,ink(end)];
        end;
    end;

    for i = r(2):r(4);
        subpix = pix(i,r(1):r(3));
        ink = find((1-subpix)>0);
        if (length(ink) > 0);
            ink = r(1) - 1 + ink;
            edges = [edges;ink(1),i];
        end;
        if (length(ink) > 1);
            edges = [edges;ink(end),i];
        end;
    end;






