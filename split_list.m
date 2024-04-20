function [Grouplist]=split_list(nlist,gName)
% Sorts out a new variable list for the specified group in gName
% If nlist=[] assumes the entire list of names is desired.
% If no vars in nlist are associated with  gName, then no data/var from
% that group will be loaded.

if isempty(nlist)
    Grouplist=[]; % All var
    return;
end


nVar=length(nlist);
cc=0;
tempty=0;
for ii=1:nVar
    tmp=strsplit(nlist{ii},'/'); % see if groups & var specified

    if strcmp(tmp{1},gName)==1
        cc=cc+1;
        if length(tmp)>1 % group/var specified
            Grouplist{cc}=tmp{2};
        else
            Grouplist{cc}=[];
            tempty=1;
        end
    else
        continue;
    end
end

if tempty
    Grouplist=[]; % requesting all variables in this group
end

if cc==0
    Grouplist=cell(1);% no variables are wanted
end
end
