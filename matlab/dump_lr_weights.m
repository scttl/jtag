function res = dump_lr_weights(w, outfile)
% DUMP_LR_WEIGHTS   Formats and writes out the contents of the structure W to 
%                   an ascii flat file.
%
%   RES = DUMP_LR_WEIGHTS(W, OUTFILE)  Attempts to write the contents of 
%   struct W (formatted along the lines of that returned by
%   CREATE_LR_WEIGHTS) out to the file named by OUTFILE passed.  If 
%   successful, RES is set to 1.  Upon any failure, an error is returned and 
%   RES is set to 0.
%
%   SEE ALSO   CREATE_LR_WEIGHTS


% CVS INFO %
%%%%%%%%%%%%
% $Id: dump_lr_weights.m,v 1.1 2003-09-22 17:47:09 scottl Exp $
% 
% REVISION HISTORY:
% $Log: dump_lr_weights.m,v $
% Revision 1.1  2003-09-22 17:47:09  scottl
% Initial revision.
%


% LOCAL VARS %
%%%%%%%%%%%%%%

separator = '---';  % used to separate each page's information
res = false;


% first do some argument sanity checking on the argument passed
error(nargchk(2,2,nargin));

% ensure that the struct has all the required fields
if ~ isfield(w, 'class_names') | ~ isfield(w, 'weights')
    error('invalid struct passed.  See CREATE_LR_WEIGHTS for info');
end

% print the header information (class names, feature names, and number of pages)
out_fid = fopen(outfile, 'w');
fprintf(out_fid, '%%\n%% LR WEIGHTS DUMP\n%%\n%% DATE: %s\n%%\n\n', ...
        datestr(clock, 0));

fprintf(out_fid, '%% HEADER DATA:\n');
fprintf(out_fid, '%% ============\n');
fprintf(out_fid, 'class_names = [\n');
for i = 1:length(w.class_names)
    fprintf(out_fid, '  %d, %s;\n', i, w.class_names{i});
end
fprintf(out_fid, ']\n\n');

fprintf(out_fid, 'weights = [\n');
for i = 1:size(w.weights,1)
    for j = 1:size(w.weights,2)
        fprintf(out_fid, '%f,', w.weights(i,j));
    end

    %go back 1 byte to replace the extraneous ','
    if fseek(out_fid, -1, 0) == -1
        flcose(out_fid);
        error('problems seeking through file.  Dump aborted!!');
    end
    fprintf(out_fid, ';\n');
end
fprintf(out_fid, ']\n\n');


% since everything went ok, return true
fclose(out_fid);
res = true;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
