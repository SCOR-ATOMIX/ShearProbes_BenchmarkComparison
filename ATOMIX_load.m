function [O]=ATOMIX_load(file_nc,groups)
% O = ATOMIX_load(file_nc,levels);
% 
% Loads the contents of the grouped NC file
% file_nc is the copmlete filename including the path
% The function is intended to load the data from the shear-probes group of
% ATOMIX
%
% All levels (groups) and attributes (global and level-wise) are loaded to
% workspace, in the structure O
% The  complete list of levels names are:  (no need to input them)
% {'L1_converted', 'L2_cleaned', 'L3_spectra','L4_dissipation','CTD', 'ANCILLARY'}
% A data file need not have CTD or ANCILLARY
%
% The level names will be simplified to:
% L1, L2, L3, L4, CTD, ANC  and Att   (or a requested subset of those)
% The last one (Att), Attributes are loaded in any case
% The global attributes are collected in O.Att.
% Group-wise attributes are collected in O.L1.PROCESS_INFO and so on.
%
% Simply put in numbers for the requested levels from the complete list
% default levels (no input) is all available levels in the file;
% Levels [1:4] load levels 1 to 4
% Levels [2 5] load levels 2 and CTD
%
% Ilker Fer, University of Bergen, 2022
% 
% 20230928: included all dependencies as subfunctions

[Att,GroupAtt] = load_netcdf_attributes(file_nc);
GrpNames = fieldnames(GroupAtt);
% Grpnames list is
list_all_names = {'L1_converted','L2_cleaned','L3_spectra','L4_dissipation','CTD','ANCILLARY'};
% simplified list
out_list_all_names = {'L1', 'L2', 'L3', 'L4', 'CTD','ANC'};


if ~isempty(GrpNames)
    if nargin<2
        % pick all groups
        for I=1:length(GrpNames)
            groups(I) = find(strcmp(lower(GrpNames(I)),lower(list_all_names)));
        end
        picked = groups;
    else
        picked = groups;
        for I=1:length(groups)
            ix = find(strcmp(lower(GrpNames),...
                lower(list_all_names(groups(I)))));
            if isempty(ix)
                fprintf(1,'Group %d not found and ignored',groups(I));
                picked(I)=[];
            end
        end

    end
    D=load_netcdf_data(file_nc,list_all_names(picked));

    for I=1:length(picked)
        eval(['O.' out_list_all_names{picked(I)} '= D.' list_all_names{picked(I)} ';'])
        eval(['O.' out_list_all_names{picked(I)} '.PROCESS_INFO= GroupAtt.' list_all_names{picked(I)} ';'])
    end
    O.Att=Att;

    if isfield(O,'L1') && ~isfield(O.L1,'PROCESS_INFO')
        O.L1.PROCESS_INFO = Att;
    end
    clear D


else
    O=load_netcdf_data(file_nc);
    O.Att=Att;

end
end

% --------------------------------
% SUBFUNCTIONS
% load_netcdf_data and load_netcdf_attributes
% and their subfunctions:
% --------------------------------




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


function newVarName=clean_names_attributes(varName)
% Takes any string, and cleans it up such that it can be used as a
% fieldname in a matlab structure. For instance, :, -, and prefixed _ are
% removed.
tmp = regexprep(varName,'\s','_');
tmp = regexprep(tmp,'^_+','');
newVarName= regexprep(tmp,'-','_');
end





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

%% subfcts
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



%% Process list of vars into groups & variables
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

%%
function dat=convert_char_cell(tmp)
% Converting characters arrays as cells
if ischar(tmp)
    dat=char2cell(tmp);
else
    dat=tmp;
end

end
