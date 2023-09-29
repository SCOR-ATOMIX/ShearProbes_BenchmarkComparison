function ind = lower10(ncfile)
%gets a segment in the lower 10 percentile of the epsilon estimates
% based on EPSI_FINAL of PI
% input:
%       ncfile - netcdf file (of PI)

   epsiPI = ncread(ncfile,'/L4_dissipation/EPSI_FINAL');
   [epsiPI_sorted,sort_ind] = sort(epsiPI);
   perc10 = (10/100)*length(epsiPI_sorted);
   ind = sort_ind(round(perc10/2)); %value in the middle of lower 10 percentile

end

