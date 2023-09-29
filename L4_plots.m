clear all
close all
clc

%% set path, data set and PI / tester

path = '/scratch/kirstin/ATOMIX/data/'; % path to the nc data files
fig_dir = './figures/'; % output directory to store figures
dataset = 'VMP250_TidalChannel_024'; % prefix of the nc files
pi_suffix = ''; % suffix of PI nc file
%tester_suffix = '_fromL3_IF'; tester_name = 'IF'; % suffix of test nc file (yours)
%tester_suffix = '_fromL3_CEB'; tester_name = 'CEB'; % suffix of test nc file (yours)
%tester_suffix = '_fromL3_ALB'; tester_name = 'ALB'; % suffix of test nc file (yours)
tester_suffix = '_CEB_samekfitted'; tester_name = 'CEB_SKF'; % suffix of test nc file (yours)

% add second file from Cynthia

%% select which figures to plot

plot_L4_epsi_timeseries = 1;
plot_L4_epsi_scatter = 1;
plot_L4_ratio_epsi = 1;


%% call plotting routines

if plot_L4_epsi_timeseries==1
   L4_timeseries_Epsilon([path dataset],pi_suffix,tester_suffix,tester_name);
   print(gcf,'-dpng',[fig_dir 'L4_timeseries_Epsilon_PI_' tester_name '.png'],'-r300')
end

if plot_L4_epsi_scatter==1
   L4_scatter_Epsilon([path dataset],pi_suffix,tester_suffix,tester_name);
   print(gcf,'-dpng',[fig_dir 'L4_Epsilon_scatter_PI_' tester_name '.png'],'-r300')
end

if plot_L4_ratio_epsi==1
   L4_ratio_Epsilon([path dataset],pi_suffix,tester_suffix,tester_name);
   print(gcf,'-dpng',[fig_dir 'L4_Epsilon_ratio_PI_' tester_name '.png'],'-r300')
end
