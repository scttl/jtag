function res = rgs_params_sanity_check(cid,feats,params);
cn=1;
pn = 1;
for fn=1:46;
    if (params.is_gaus(fn));
        ff=feats(find(cid==cn),fn);
        mn = mean(ff);
        subplot(7,5,pn);
        pn = pn + 1;
        hist(ff,100);
        title(strrep(params.feat_names{fn},'_','-'));
        line([params.means(cn,fn) params.means(cn,fn)],[0 500]); 
        line([mn mn], [0 500], 'color', 'red');
        line([(params.means(cn,fn)+params.sigmas(cn,fn)), ...
              (params.means(cn,fn)-params.sigmas(cn,fn))],[200 200]); 
        %pause; 
    end;
end;
res = 1;
