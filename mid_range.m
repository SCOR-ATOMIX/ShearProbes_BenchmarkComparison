function ind = mid_range(ncfile)
%gets a segment in the mid range of the epsilon estimates
% based on EPSI_FINAL of PI
% input:
%       ncfile - netcdf file (of PI)

   epsiPI = ncread(ncfile,'/L4_dissipation/EPSI_FINAL');
   [~,sort_ind] = sort(epsiPI);
   ind = sort_ind(round(length(epsiPI)/2));

end
