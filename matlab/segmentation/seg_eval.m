function cost = seg_eval(p,segs)
%function cost = seg_eval(p,segs)
%  p is a pixel map from imread()
%  segs is a segmentation like that returned by xycut
%
%First attempt at a cost function for segmentation
%Basic idea: every black pixel missed is worth 100
%            every white pixel included is worth 1

OnesInSegs = zeros(size(p));
for ii = 1 : size(segs,1);
  OnesInSegs(segs(ii,2):segs(ii,4),segs(ii,1):segs(ii,3)) = 1;
end;

cost = sum(sum(OnesInSegs .* p));
cost = cost + (100 * (sum(sum((1 - OnesInSegs) .* (1 - p)))));


