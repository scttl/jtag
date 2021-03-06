function res = dump_training_data(s, outfile)
% DUMP_TRAINING_DATA   Formats and writes out the contents of the structure S 
%                      to an ascii flat file.
%
%   RES = DUMP_TRAINING_DATA(S, OUTFILE)  Attempts to write the contents of 
%   struct S (formatted along the lines of that returned by
%   CREATE_TRAINING_DATA) out to the file named by OUTFILE passed.  If 
%   successful, RES is set to 1.  Upon any failure, an error is returned and 
%   RES is set to 0.
%
%   SEE ALSO   CREATE_TRAINING_DATA


% CVS INFO %
%%%%%%%%%%%%
% $Id: dump_training_data.m,v 1.3 2004-07-20 02:21:44 klaven Exp $
% 
% REVISION HISTORY:
% $Log: dump_training_data.m,v $
% Revision 1.3  2004-07-20 02:21:44  klaven
% Changing training data format from text to .mat
%
% Revision 1.2  2004/07/16 20:28:51  klaven
% Assorted changes made to accommodate memm.
%
% Revision 1.1  2004/06/19 00:27:27  klaven
% Re-organizing files.  Third step: re-add the files.
%
% Revision 1.2  2003/09/22 17:46:48  scottl
% Fixed incorrect comment.
%
% Revision 1.1  2003/08/19 20:51:55  scottl
% Initial revision.
%
if (strcmp(outfile(end-3:end), '.mat'));
    saveddatavar = s;
    evalstr = ['save ' outfile ' saveddatavar;'];
    eval(evalstr);
    res = 1;
    return;
end;


% LOCAL VARS %
%%%%%%%%%%%%%%

separator = '---';  % used to separate each page's information
res = false;


% first do some argument sanity checking on the argument passed
error(nargchk(2,2,nargin));

% ensure that the struct has all the required fields
if ~ isfield(s, 'class_names') | ~ isfield(s, 'num_pages') | ...
   ~ isfield(s, 'pg_names') | ~ isfield(s, 'feat_names') | ...
   ~ isfield(s, 'pg')
    error('invalid struct passed.  See CREATE_TRAINING_DATA for info');
end

% print the header information (class names, feature names, and number of pages)
out_fid = fopen(outfile, 'w');
fprintf(out_fid, '%%\n%% TRAINING DATA DUMP\n%%\n%% DATE: %s\n%%\n\n', ...
        datestr(clock, 0));

fprintf(out_fid, '%% HEADER DATA:\n');
fprintf(out_fid, '%% ============\n');
fprintf(out_fid, 'class_names = [\n');
for i = 1:length(s.class_names)
    fprintf(out_fid, '  %d, %s;\n', i, s.class_names{i});
end
fprintf(out_fid, ']\n\n');

fprintf(out_fid, 'feat_names = [\n');
for i = 1:length(s.feat_names)
    fprintf(out_fid, '  %d, %s;\n', i, s.feat_names{i});
end
fprintf(out_fid, ']\n\n');

fprintf(out_fid, 'num_pages = %d\n\n', s.num_pages);

if (isfield(s,'label_feats_added') && s.label_feats_added);
    fprintf(out_fid, 'label_feats_added = 1\n\n');
else;
    fprintf(out_fid, 'label_feats_added = 0\n\n');
end;


% loop through each page to print its data
fprintf(out_fid, '%% PAGE DATA:\n');
fprintf(out_fid, '%% ==========\n');
for i = 1:length(s.pg)
    fprintf(out_fid, '%s\n', separator);
    fprintf(out_fid, 'pg_name = %s\n', s.pg_names{i});
    fprintf(out_fid, 'pg_data = [\n');
    for j = 1:length(s.pg{i}.cid)
        fprintf(out_fid, '%d:', s.pg{i}.cid(j));
        fprintf(out_fid, '%f,', s.pg{i}.features(j,:));

        %go back 1 byte to replace the extraneous ','
        if fseek(out_fid, -1, 0) == -1
            fclose(out_fid);
            error('problems seeking through file.  Dump aborted!!');
        end

        fprintf(out_fid, ';\n');
    end
    fprintf(out_fid, ']\n\n');
end

% since everything went ok, return true
fclose(out_fid);
res = true;


% SUBFUNCITON DECLARATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
