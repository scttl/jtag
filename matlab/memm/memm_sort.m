function td_out = memm_sort(td_in); 
% function td_out = memm_sort(td_in);
%
% Sorts td for use with Markov Models.
%

if (isfield(td_in, 'isSorted') && td_in.isSorted);
    td_out = td_in;
    fprintf('Data is already sorted.\n');
    return;
end;

td = td_in;
td_out.class_names = td_in.class_names;
td_out.num_pages = td_in.num_pages;
td_out.pg_names = td_in.pg_names;
td_out.feat_names = td_in.feat_names;

fprintf('Beginning to sort...\n');
for pp = 1:length(td.pg);
    fprintf('    Sorting page %i of %i...\n', pp, length(td.pg));
    jt = parse_jtag(td.pg_names{pp});
    pg.cid = zeros(size(td_in.pg{pp}.cid));
    pg.features = zeros(size(td_in.pg{pp}.features));
    for ff = 1:length(td.pg{pp}.cid);
        correctOrder = 1;
        for ff2 = 1:length(td.pg{pp}.cid);
            if (ComesBefore(ff2,ff,jt));
                correctOrder = correctOrder + 1;
            end;
        end;
        pg.cid(correctOrder) = td_in.pg{pp}.cid(ff);
        pg.features(correctOrder,:) = td_in.pg{pp}.features(ff,:);
        td_out.pg{pp} = pg;
    end;
end;

td_out.isSorted = true;
fprintf('\nSorting complete.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunction declarations

function yn = ComesBefore(ind1,ind2,jt);
% Returns true if 1 comes before 2,
%         false if 2 comes before 1,
%         false if 1 and 2 come at the same time.
    useSlope = 30;
    %If either ind is beyond the range of jt.rects, then it is the
    %end_of_page marker, and should be last.
    if (ind1 > size(jt.rects,1));
        yn = false;
    elseif (ind2 > size(jt.rects,1));
        yn = true;
    else;
        if (((useSlope * jt.rects(ind1,2)) + jt.rects(ind1,1)) < ...
            ((useSlope * jt.rects(ind2,2)) + jt.rects(ind2,1)));
            yn = true;
        else
            yn = false;
        end;
    end;
