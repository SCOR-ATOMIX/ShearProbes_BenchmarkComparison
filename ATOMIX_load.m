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
% 20240420: separated the subfunctions out again - Kiki

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
