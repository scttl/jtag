function [choices,score] = best_path(score_mat_y,score_mat_n);

if (nargin < 2);
    score_mat_n = zeros(size(score_mat_y));
end;

if (size(score_mat_y,1) ~= size(score_mat_y,2));
    error('ERROR: score matrix for best_path must be square.');
end;

%Create a "path" and "score" with just the first candidate set to yes.
path.yes = [1];
path.score_sum = 0;
paths = path;
%For each candidate, find the best path up to it when it is a yes:
for i = 2:size(score_mat_y,1);
    %For each "path" in our list, check if it creates the best path in
    %which this candidate is a 1.
    %Whether it does or not, update the score for that path to include
    %all of the additional "not_a_segment" labels added to it.
    bestscore = -inf;
    bestpath = [];

    score_vect_y = score_mat_y(:,i);
    score_vect_n = score_mat_n(:,i);
        
    for j=1:length(paths);
        path = paths(j);
        
        %Add this cut to the "path", and re-score it.
        path.score_sum = path.score_sum + score_vect_y(path.yes(end)) + ...
                         sum(score_vect_n(1:path.yes(end)-1)) + ...
                         sum(score_vect_n(path.yes(end)+1:end));
        path.yes = [path.yes;i];
            
        if (path.score_sum) > bestscore;
            bestpath = path;
            bestscore = path.score_sum;
        end;

        %Now update the score for this path to reflect all the additional
        %not_a_segments that have been added.
        paths(j).score_sum = paths(j).score_sum + sum(score_vect_n);
    end;

    paths = [paths;bestpath];
end;

choices = bestpath.yes;
score = bestpath.score_sum;
