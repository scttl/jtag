function res = fixsnapping(jtdir,logfile);
% function res = fixsnapping(jtdir,logfile);



files = dir(strcat(jtdir, '/*.jtag'));

bg = 1;

fid = fopen(logfile,'w');

fprintf('Found %i jtag files.\n',length(files));

for i=1:length(files);

    jt = parse_jtag([jtdir, files(i).name]);
    jt.jlog_file = [jt.jtag_file(1:end-4), 'jlog'];

    fprintf('File %i of %i: %s.\n', i, length(files), jt.jtag_file);

    pixels = imread(jt.img_file);
    for j=1:size(jt.rects,1);
        left = jt.rects(j,1);
        top = jt.rects(j,2);
        right = jt.rects(j,3);
        bottom = jt.rects(j,4);

        if (top > bottom);
            tmp = top;
            top = bottom;
            bottom = top;
            fprintf('    Fixing top/bottom inversion\n');
        end;

        if (left > right);
            tmp = left;
            left = right;
            bottom = tmp;
            fprintf('    Fixing left/right inversion\n');
        end;

        % First, move the edges in as needed.
        done = false;
        while (done == false);
            done = true;
            %Left
            if ((left > 1) && ...
                (sum(bg - pixels(top:bottom,left)) > 0) && ...
                (sum(bg - pixels(top:bottom,left-1)) > 0) ...
               );
                left = left - 1;
                done = false;
            elseif ((left < right) && ...
                    (sum(bg - pixels(top:bottom,left)) == 0) && ...
                    (sum(bg - pixels(top:bottom,left+1)) == 0) ...
                   );
                left = left + 1;
                done = false;
            end;
            %Right
            if ((right < size(pixels,2)) && ...
                (sum(bg - pixels(top:bottom,right)) > 0) && ...
                (sum(bg - pixels(top:bottom,right+1)) > 0) ...
               );
                right = right + 1;
                done = false;
            elseif ((right > left) && ...
                    (sum(bg - pixels(top:bottom,right)) == 0) && ...
                    (sum(bg - pixels(top:bottom,right-1)) == 0) ...
                   );
                right = right - 1;
                done = false;
            end;
            %Top
            if ((top > 1) && ...
                (sum(bg - pixels(top,left:right)) > 0) && ...
                (sum(bg - pixels(top-1,left:right)) > 0) ...
               );
                top = top - 1;
                done = false;
            elseif ((top < bottom) && ...
                    (sum(bg - pixels(top,left:right)) == 0) && ...
                    (sum(bg - pixels(top+1,left:right)) == 0) ...
                   );
                top = top + 1;
                done = false;
            end;
            %Bottom
            if ((bottom < size(pixels,1)) && ...
                (sum(bg - pixels(bottom,left:right)) > 0) && ...
                (sum(bg - pixels(bottom+1,left:right)) > 0) ...
               );
                bottom = bottom + 1;
                done = false;
            elseif ((bottom > top) && ...
                    (sum(bg - pixels(bottom,left:right)) == 0) && ...
                    (sum(bg - pixels(bottom-1,left:right)) == 0) ...
                   );
                bottom = bottom - 1;
                done = false;
            end;
        end;
        
        if (any(jt.rects(j,:) - [left,top,right,bottom]));
            fprintf('    Box %i: ', j);
            fprintf('(%i>%i),(%i>%i),(%i>%i),(B:%i>%i)\n', ...
                    jt.rects(j,1), left, jt.rects(j,2), top, ...
                    jt.rects(j,3), right, jt.rects(j,4), bottom);

            jt.rects(j,1) = left;
            jt.rects(j,2) = top;
            jt.rects(j,3) = right;
            jt.rects(j,4) = bottom;
        end;
    end;
    
    pmap = zeros(size(pixels));
    for j = 1:size(jt.rects,1);
        r1 = zeros(size(pixels));
        r1(jt.rects(j,2):jt.rects(j,4),jt.rects(j,1):jt.rects(j,3)) = 1;
        pmap = pmap + r1;
    end;
    if (max(max(pmap)) > 1);
        fprintf('    PROBLEM: Overlapping rects in %s\n', jt.jtag_file);
        fprintf(fid,'Overlapping rects in %s\n', jt.jtag_file);
    end;
%         for k = i+1:size(jt.rects,1);
%             % Check for intersection.
%             r2 = zeros(size(pixels));
%             r2(jt.rects(k,2):jt.rects(k,4),jt.rects(k,1):jt.rects(k,3)) = 1;
%             
%             if (any(r1 .* r2));
%                 fprintf('PROBLEM: Overlapping rects in %s', jt.jtag_file);
%             end;
%         end;
%     end;

    dump_jfiles(jt);
end;

fclose(fid);

