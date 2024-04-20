function [AllData,VarName,newName] = load_netcdf_data(filename,nlist)
%function [Data,varName] = load_netcdf(filename,nlist)
%  Load the NetCDF  data in "filename" into a matlab struct
%  Can optionally request a subset of data.
% Handles "flat" NetCDF or one-level deep NetCDF groups (ATOMIX-SCOR format)
% Optional Input:
%   nlist: cell array of desired variables if known...
%           Use  ncdisp('name_of_file.nc','/') to identify variables and
%           avoid loading too much data.
%           Alternatively: ncdisp('name_of_file.nc','GroupName/') for
%           variables stored in GroupName
%   It now works with flat NetCDFs and hierarchical NetCDF (1 level deep)
%       e.g., nlist={'Level1/TIME','Level1/PRES','Level2'} will load
%       TIME & PRES variables in group Level1, and ALL variables in Level2.
%       To read "ALL" Global level data,  specify 'Global'.
%       IF you want ONE Global variable (e.g. TIME), then you can specify
%       'TIME' OR 'Global/TIME'
% Outputs:
%   AllData: structure of the data in NetCDF in the same hierarchal format.
%        If NetCDF is flat, then each fields will have the same names as
%           the short_name variables in the NetCDF
%       If NetCDF has grouped data, then each field represent a structure
%       with the group's name. The fields in each group's structure
%       represent the variable field1 (e.g. AllData.group1.field1)
%   VarName: structure (grouped NetCDF) or cell array (flat NetCDF) of
%       possible variable names that can be loaded.
%   newName: is cell array (nvars x 3columns) with the entire list
%       The 1st column is the group, 2nd column the var, 3rd is properly
%       merged tother group/var
% Created by CBluteau in Oct 2017 when I couldn't open a netcdf file in
% ncview/ncbrowse.
% Modifications
%   2021/09/28. CB accomodated requesting subset of variables from NetDCF groups.
%%%
% Initialise/defaults
if nargin<2
    nlist=[];
end

AllData=struct;
VarName=struct;
%%
% ILKER: commented out because I give full path to filename
% [~,filename]=fileparts(filename);
% filename=[filename,'.nc'];

nInfo=ncinfo(filename);
ncid = netcdf.open(filename,'NOWRITE');
gInfo=nInfo.Groups;
%%
gid=ncid;
gName{1}='Global';
if ~isempty(gInfo)
    nG=length(gInfo);
    for kk=1:nG
        gName{kk+1}=gInfo(kk).Name;
        gid(kk+1) = netcdf.inqNcid(ncid,gName{kk+1});
    end
end

%% Loop
nG=length(gid);

for kk=1:nG
    disp(['Trying to load group data: ',gName{kk}])
    varids = netcdf.inqVarIDs(gid(kk));

    if isempty(varids)
        continue;
    end


    for ii=1:length(varids)
        VarName.(gName{kk}){ii}=netcdf.inqVar(gid(kk),varids(ii));
    end

    if strcmp(gName{kk},'Global')
        if any(strcmpi(nlist,'Global'))
            group_list=[]; % load the entire top (Global) list of vars
        else
            [extra_list]=split_list(nlist,gName{kk}); % handles the format Global/varname
            group_list=[nlist extra_list];% assign nlist and those that are "Global" will be loaded. Redundant variables, but the other checks will deal with this "bug
        end
    else
        [group_list]=split_list(nlist,gName{kk});
    end


    if isempty(group_list)
        nVar= VarName.(gName{kk});
    else
        if isempty(group_list{1})==1 % no variables desired
            % VarName=rmfield(VarName,gName{kk});
            continue;
        else
            [nVar,varids]=getvarName(VarName.(gName{kk}),varids,group_list);
        end
    end

    for ii=1:length(varids)
        if strcmp(gName{kk},'Global')==0
            tmp = netcdf.getVar(gid(kk),varids(ii));
            AllData.(gName{kk}).(nVar{ii})=convert_char_cell(tmp);

        else
            tmp = netcdf.getVar(gid(kk),varids(ii));
            AllData.(nVar{ii})=convert_char_cell(tmp);
        end
    end

    clear Data;
end


%% Assign possible varnames to newNAmes and struct VarName
if  all([nG==1 strcmp(gName{1},'Global')])
    % %      AllData=AllData.(gName{1});
    VarName=VarName.(gName{1});
    newName=VarName;
else

    vF=fieldnames(VarName);
    cc=0;
    for kk=1:length(vF)
        tmpName=VarName.(vF{kk});
        nF=length(tmpName);
        for ii=1:nF
            cc=cc+1;
            newName{cc,1}=vF{kk};
            newName{cc,2}=tmpName{ii};
            switch vF{kk}
                case{'Global'}
                    newName{cc,3}=tmpName{ii}; % didn't want the word Global
                otherwise
                    newName{cc,3}=[vF{kk},'/',tmpName{ii}];
            end
        end
    end
end
%ILKER:
netcdf.close(ncid)

end % end load_netcdf_data

