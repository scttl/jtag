function jt = jt_load(fpath, plot_it);
%
% function jt = jt_load(fpath, plot_it);
% 
% Loads and optionally plots the tagged journal at fpath.
%
% Inputs:  fpath is the path to the .jtag file
%          plot_it is false if you do not want to plot the file,
%                     true or omitted if you do want to plot it
%
% Output:  jt is a structure containing the jtag information of
%                the file at fpath.
%


% parse file_name to determine name of jtag and jlog files

dot_idx = regexp(fpath, '\.');
jtpath = strcat(fpath(1:dot_idx(length(dot_idx))), 'jtag');
jt = parse_jtag(jtpath);
jt.jtag_file = jtpath;
jt.jlog_file = strcat(fpath(1:dot_idx(length(dot_idx))), 'jlog');
jt = parse_jlog(jt.jlog_file,jt);

impath = jt.img_file;
d_idx = regexp(impath, '\.');
impath = strcat(fpath(1:dot_idx(length(dot_idx))), ...
                impath(d_idx(length(d_idx))+1:end));
%fprintf('Loading image from %s\n',impath);
jt.img_file = impath;

if ((nargin < 2) || (plot_it));
    jt = jt_plot(jt);
end;
