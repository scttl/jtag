function [] = assert(condition,message)

if nargin == 1,message = '';end
if(~condition) 
  ddd = dbstack;
  if(length(ddd)>1) dname=ddd(2).name; else dname='command line'; end
  warning('!!! assert failure (%s)!!!\n    in function %s\n',...
      message,dname); 
end

