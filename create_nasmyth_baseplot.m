function fNas=create_nasmyth_baseplot
%colsym=lines(5); colsym(3,:)=[.9 .9 0]; colsym(4,:)=[1 .5 0]; colsym(5,:)=[.8 0 0.7];
%colfit(1,:)=[0 0.7 1];colfit(2,:)=[0 1 .1]; % brighter green and blue
%% Background Nasmyth spectrum plot

% create the base plot with theoretical Nasmyth
visc=1e-6;
k=logspace(-2,4,200);
epsi=logspace(-11,-3,9);
[phi,pk]=nasmyth(epsi,visc,k); % creating theor spectra with rsi’s nasmyth code
[phi_int]=nasmyth_integral(epsi,visc,k); % creating theor spectra with rsi’s nasmyth code



fNas=gcf;
col=cmocean('gray',length(epsi)) ;   
%set(gcf,'defaultAxesColorOrder',col)

loglog(pk,phi,'-.','color',.4*[1 1 1]); % label it o
hold on;
for ii=1:length(epsi)
    tmpdat=phi_int(:,ii)./epsi(ii);
    ind=find(tmpdat>=0.05 & tmpdat<=.96);
    htxt(ii)=text(pk(ind(1),ii)./2,phi(ind(1),ii),[char(949),'=',num2str(epsi(ii),'%3.0d')]);
%     ind=find(tmpdat>=0.01,1,'first');
%     loglog(pk(ind,ii),phi(ind,ii),'k.')
%     ind=find(tmpdat>=0.05,1,'first');
%     loglog(pk(ind,ii),phi(ind,ii),'ks')
%     ind=find(tmpdat>=0.1,1,'first');
%     loglog(pk(ind,ii),phi(ind,ii),'kd')
    phiInt(:,ii)=tmpdat;
end
 set(htxt,'verticalAlignment','bottom','fontsize',8); clear ht;


xlabel('k [cpm]'); ylabel('Spectra [s^{-2}/cpm]')

axP=gca;
xli=get(gca,'xlim');
xliP=[1e-1 xli(2)]; yliP=[1e-10 1e1];
 