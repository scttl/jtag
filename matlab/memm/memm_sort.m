function td = memm_sort(td_in); 
% function td = memm_sort(td_in);
%
% Sorts td for use with Markov Models.
%
% Each pg in td_in gets an array of ordered_index values.
%     -td.pg{1}.cid(td.pg{1}.ordered_index(3)) returns the 3rd cid.
%     -td.pg{1}.cid(td.pg{1}.ordered_index(:)) returns the entire
%      list of cid's in order.
%     -td.pg{1}.features(td.ordered_index(3),:) returns the 3rd feature
%      vector.
%     -td.pg{1}.features(td.ordered_index(:),:) returns all of the
%      feature vectors, in order.
%

if (isfield(td_in, 'isSorted') && td_in.isSorted);
    td = td_in;
    fprintf('Data is already sorted.\n');
    return;
end;

td = td_in;

fprintf('Beginning to sort...\n');
for pp = 1:length(td.pg);
    pg = td.pg{pp};
    fprintf('    Sorting page %i of %i...\n', pp, length(td.pg));
    jt = parse_jtag(td.pg_names{pp});
    pg.ordered_index = zeros(size(pg.cid));
    for ff = 1:length(td.pg{pp}.cid);
        correctOrder = 1;
        for ff2 = 1:length(td.pg{pp}.cid);
            if (ComesBefore(ff2,ff,jt));
                correctOrder = correctOrder + 1;
            end;
        end;
        pg.ordered_index(correctOrder) = ff;
        td.pg{pp} = pg;
    end;
end;

td.isSorted = true;
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
        yn = rect_comes_before(jt.rects(ind1,:),jt.rects(ind2,:));
        %if (((useSlope * jt.rects(ind1,2)) + jt.rects(ind1,1)) < ...
        %    ((useSlope * jt.rects(ind2,2)) + jt.rects(ind2,1)));
        %    yn = true;
        %else
        %    yn = false;
        %end;
    end;
