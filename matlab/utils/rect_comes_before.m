function yn = rect_comes_before(rect1,rect2);
%
%function yn = rect_comes_before(rect1,rect2);
%
% Each rect should be [left top bottom right]
%
% Returns true if rect1 comes before rect2
%         false if rect2 comes before rect1
%         false if rect1 and rect2 come at the same time
%
useSlope = 30;
if ((useSlope * rect1(2) + rect1(1)) < ...
    (useSlope * rect2(2) + rect2(1)));
    yn = true;
else
    yn = false;
end;


