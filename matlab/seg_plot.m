function MM = seg_plot(pixels, segs);

%functon function MM = seg_plot(pixels, segs);
%Plots the image pixels with the segmentation segs
%Segs:   L1  T1  R1  B1
%        L2  T2  R2  B2
%        L3  T3  R3  B3
%        ...

%set(0,'DefaultFigurecolormap',gray);
h = figure;
imagesc(pixels); axis equal; axis off; colormap gray;
%line([[L1;R1],[L2;R2],[L3;R3],...],[[T1;B1],[T2;B2],[T3;B3],...]);
%line( L1 L2 L3 ...
%      R1 R2 R3 ...
%line([segs(:,1)';segs(:,3)'],[segs(:,2)';segs(:,2)'],'Color','b');
%line([segs(:,1)';segs(:,3)'],[segs(:,4)';segs(:,4)'],'Color','b');
%line([segs(:,1)';segs(:,1)'],[segs(:,2)';segs(:,4)'],'Color','b');
%line([segs(:,3)';segs(:,3)'],[segs(:,2)';segs(:,4)'],'Color','b');

%Draw boxes around each of the segments.
patch([segs(:,1),segs(:,3),segs(:,3),segs(:,1)]', ...
      [segs(:,2),segs(:,2),segs(:,4),segs(:,4)]', ...
      'r','FaceColor','none');


