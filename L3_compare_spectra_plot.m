function [] = L3_compare_spectra_plot(dataset,pi,tester,tester_name,section)
%L3_COMPARE_SPECTRA_PLOT compares PI and tester spectra 
% input:
%   dataset = path and prefix data set
%   pi = suffix PI data set (without .nc ending)
%   tester = suffix tester data set (without .nc ending)
%   tester_name = ID of tester for figure legend and file name
%   section = section in record to plot

filePI = [dataset pi '.nc'];
fileTEST = [dataset tester '.nc'];

ncdisp(fileTEST)

% read in eps value and spectra
epsiPI = ncread(filePI,'/L4_dissipation/EPSI',[section 1],[1 Inf]);
epsiTEST = ncread(fileTEST,'/L4_dissipation/EPSI',[section 1],[1 Inf]);
specRawPI = squeeze(ncread(filePI,'/L3_spectra/SH_SPEC',[section 1 1],[1 Inf Inf]));
specRawTEST = squeeze(ncread(fileTEST,'/L3_spectra/SH_SPEC',[section 1 1],[1 Inf Inf]));
specCleanPI = squeeze(ncread(filePI,'/L3_spectra/SH_SPEC_CLEAN',[section 1 1],[1 Inf Inf]));
specCleanTEST = squeeze(ncread(fileTEST,'/L3_spectra/SH_SPEC_CLEAN',[section 1 1],[1 Inf Inf]));

kvisc = ncread(filePI,'L4_dissipation/KVISC',section,1);
n = size(epsiPI,2); % number shear probes

% wvn, min and max wvn
kcycPI = ncread(filePI,'/L3_spectra/KCYC',[section 1],[1 Inf]);
kcycTEST = ncread(fileTEST,'/L3_spectra/KCYC',[section 1],[1 Inf]);

kminPI = ncread(filePI,'L4_dissipation/KMIN',[section 1],[1 Inf]);
kmaxPI = ncread(filePI,'L4_dissipation/KMAX',[section 1],[1 Inf]);

try
    kminTEST = ncread(fileTEST,'L4_dissipation/KMIN',[section 1],[1 Inf]);
catch 
   kminTEST = 0*ones(1,n);
   disp('No KMIN specified.')
end

kmaxTEST = ncread(fileTEST,'L4_dissipation/KMAX',[section 1],[1 Inf]);

% plotting
figure('rend','painters','pos',[10 10 1000 1000])
FS = 12;

%raw spectra
for ii=1:n  
    % fitlines
    ktPI = linspace(kminPI(ii),kmaxPI(ii),20);
    PtPI = nasmyth(epsiPI(ii),kvisc,ktPI);
    ktTEST = linspace(kminTEST(ii),kmaxTEST(ii),20);
    PtTEST = nasmyth(epsiTEST(ii),kvisc,ktTEST);
    
    subplot(2,n,ii)
    fNas=create_nasmyth_baseplot; % create Nasmyth background from CB
    hold on
    loglog(kcycPI,specRawPI(:,ii),'Color',[0.8 0.38 0.08])
    loglog(kcycPI,specRawTEST(:,ii),'Color','k')    
    hold off
    ylabel('Raw shear spectra (s^-^2 cpm^-^1)')
    box on
    grid on
    xlim([1e-1 1e3])
    ylim([1e-10 1e0])   
    set(gca,'FontSize',FS)
end

% clean spectra
for ii=1:n  
    % fitlines
    ktPI = linspace(kminPI(ii),kmaxPI(ii),20);
    PtPI = nasmyth(epsiPI(ii),kvisc,ktPI);
    ktTEST = linspace(kminTEST(ii),kmaxTEST(ii),20);
    PtTEST = nasmyth(epsiTEST(ii),kvisc,ktTEST);
    
    subplot(2,n,ii+n)
    fNas=create_nasmyth_baseplot; % create Nasmyth background from CB
    hold on
    p1 = loglog(kcycPI,specCleanPI(:,ii),'Color',[0.8 0.38 0.08]);
    p2 = loglog(kcycTEST,specCleanTEST(:,ii),'Color','k');
    hold off
    ylabel('Clean shear spectra (s^-^2 cpm^-^1)')
    legend([p1 p2],{['PI,',char(949),'=',num2str(epsiPI(ii),'%3.1d')],...
        [tester_name,',',char(949),'=',num2str(epsiTEST(ii),'%3.1d')]},...
        'Location','SouthWest','FontSize',FS) 
    box on
    grid on
    xlim([1e-1 1e3])
    ylim([1e-10 1e0])   
    set(gca,'FontSize',FS)
end



end

