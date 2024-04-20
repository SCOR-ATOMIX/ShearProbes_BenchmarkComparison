function [nVar,vIds]=getvarName(varName,varids,nlist)
cc=0;
for ii=1:length(nlist)
    ind=find(strcmp(nlist{ii},varName));

    if isempty(ind)
        warning(['Variable ', nlist{ii},' doesnt exist for this group']);
    else
        cc=cc+1;
        nVar{cc}=varName{ind};
        vIds(cc)=varids(ind);
    end
end
end
