function jt = colourguide;
%
% function jt = colourguide;
%
% Plots the colourguide image.  This image should be used with
% tagged journals to tell which colours represent which types
% of regions.
%
% Output: jt is a struct containing the jtag information of
%            the colour guide file.
%

jt = jt_load('./utils/colour_guide.jtag',1);

f = get(0,'CurrentFigure');

pos = get(f,'Position');

pos = pos + [700,0,-300,0];

set(f,'Position',pos);


