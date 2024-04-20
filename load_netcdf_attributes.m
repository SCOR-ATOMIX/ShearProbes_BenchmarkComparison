function [Att,GroupAtt] = load_netcdf_attributes(filename)
% Att = load_netcdf_attributes(filename)
% fetch all global attributes from an NC file to a structure Att.
% Field % names are the attribute names.
% Required input:
%    filename: string of the filename including .nc OR it's the output from
%    ncinfo i.e., a structure.
% Ilker Fer, 20220512
% CBluteau - dealt with attribute names starting with underscores (no idea
% why they are writing them that way!)
%      Added ability to read attributes at group level
%

if isstruct(filename)
    ncInfo=filename;
else
    ncInfo=ncinfo(filename);
end
nGr=length(ncInfo.Groups);

Att=read_atts(ncInfo);
if nGr==0
    GroupAtt=struct([]);
    return;
end

for kk=1:nGr
    A=ncInfo.Groups(kk);
    GroupAtt.(A.Name)=read_atts(A);
end
end
