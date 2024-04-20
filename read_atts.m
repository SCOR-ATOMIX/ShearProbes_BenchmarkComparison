function Att=read_atts(nInfo)
% nInfo could be the output from e.g., nInfo=ncinfo; or  group
% info=nInfo.Groups(gid) (with gid=1, 2  etc) or even varInfo=nInfo.Variables(vId)
% Outputs all the attributes associated with the passed info structure.
nAtt=length(nInfo.Attributes);
if nAtt==0
    Att=struct([]);
else
    for I=1:nAtt
        name=clean_names_attributes(nInfo.Attributes(I).Name);
        val = nInfo.Attributes(I).Value;

        Att.(name)=val;
        clear name val

    end
end
end
