function res = randpicks(vals,cols,rows);

if (nargin < 2);
    cols = 1;
end;
if (nargin < 3);
    rows = 1;
end;

needed = rows * cols;

if (needed > length(vals));
    error(1734, 'ERROR in randpicks: More picks requested than available.');
end;

picks = randperm(length(vals));

picks = picks(1:needed);

res = reshape(vals(picks),cols,rows);
    

