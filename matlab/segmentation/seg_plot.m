function MM = seg_plot(pixels, segs, colours);

%functon function MM = seg_plot(pixels, segs);
%Plots the image pixels with the segmentation segs
%Segs:   L1  T1  R1  B1
%        L2  T2  R2  B2
%        L3  T3  R3  B3
%        ...
f = figure; 
set(f,'Position',[100,100,500,700], 'ColorMap',gray); 
a = axes; 
i = imagesc(pixels); 
axis equal; 
axis off; 
axis tight; 
set(a,'Position',[-0,0.05,1,0.9]);

%line([[L1;R1],[L2;R2],[L3;R3],...],[[T1;B1],[T2;B2],[T3;B3],...]);
%line( L1 L2 L3 ...
%      R1 R2 R3 ...
if (nargin == 3);
    for i=1:size(segs,1);
        line([segs(i,1)';segs(i,3)'],[segs(i,2)';segs(i,2)'], ...
             'Color',colours(:,i), 'LineWidth',3);
        line([segs(i,1)';segs(i,3)'],[segs(i,4)';segs(i,4)'], ...
             'Color',colours(:,i), 'LineWidth',3);
        line([segs(i,1)';segs(i,1)'],[segs(i,2)';segs(i,4)'], ...
             'Color',colours(:,i), 'LineWidth',3);
        line([segs(i,3)';segs(i,3)'],[segs(i,2)';segs(i,4)'], ...
             'Color',colours(:,i), 'LineWidth',3);
    end;
else;
    line([segs(:,1)';segs(:,3)'],[segs(:,2)';segs(:,2)'],'Color','b');
    line([segs(:,1)';segs(:,3)'],[segs(:,4)';segs(:,4)'],'Color','b');
    line([segs(:,1)';segs(:,1)'],[segs(:,2)';segs(:,4)'],'Color','b');
    line([segs(:,3)';segs(:,3)'],[segs(:,2)';segs(:,4)'],'Color','b');
end;

%Draw boxes around each of the segments.
%patch([segs(:,1),segs(:,3),segs(:,3),segs(:,1)]', ...
%      [segs(:,2),segs(:,2),segs(:,4),segs(:,4)]', ...
%      'r');

%patch([segs(:,1),segs(:,3),segs(:,3),segs(:,1)]', ...
%      [segs(:,2),segs(:,2),segs(:,4),segs(:,4)]', ...
%      'r','FaceColor','none');


