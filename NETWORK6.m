%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Aircraft and Network Optimization - NETWORK MODULE
%
% AUTHOR: José Alexandre Fregnani
%
% VERSION: 5.0 / December 2018 - Network optimiztion with 3 aircraft + NPV
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic

clc
close all
clear all

% LOAD AIRCRAFT DATA

calctype=1;% 1:RANDOM SAMPLE  2:KNOWN SAMPLE 3:BASIC AIRCRAFT
mode=1;% acft seletiom method: PAX:mode=1, RANGE:mode=2
rvar=0;% random distribution of delay: 1:on 0:off

switch calctype
    case 1 
         X1=rand(1);
         X2=rand(1);
         X3=rand(1);          
        [ACFT1,ACFT2,ACFT3,LIM1,LIM2,LIM3,n1,n2,n3]=LOADDATABANK2b(X1,X2,X3,mode);
    case 2              
         n1=6;
         n2=20;
         n3=3;
        [ACFT1,ACFT2,ACFT3,LIM1,LIM2,LIM3]=LOADDATABANK3b(n1,n2,n3,mode); 
    case 3
        [ACFT]=LOADDATABANK_BASIC();
        ACFT1=ACFT;
        ACFT2=ACFT;
        ACFT3=ACFT;
        LIM1=130;
        LIM2=130;
        LIM3=130;
        n1=1;
        n2=1;
        n3=1;
end

RANGE1=ACFT1.RANGE;
RANGE2=ACFT2.RANGE;
RANGE3=ACFT3.RANGE;
NPax1 =round(ACFT1.NPax);
NPax2 =round(ACFT2.NPax);
NPax3 =round(ACFT3.NPax);
MTOW1 =round(ACFT1.MTOW);
MTOW2 =round(ACFT2.MTOW);
MTOW3 =round(ACFT3.MTOW);
wS1 =ACFT1.wS;
wS2 =ACFT2.wS;
wS3 =ACFT3.wS;
wAR1 =ACFT1.wAR;
wAR2 =ACFT2.wAR;
wAR3 =ACFT3.wAR;
ebypass1 =ACFT1.ebypass;
ebypass2 =ACFT2.ebypass;
ebypass3 =ACFT3.ebypass;
ediam1 =ACFT1.ediam;
ediam2 =ACFT2.ediam;
ediam3 =ACFT3.ediam;
Tmax1  =ACFT1.MAXRATE;
Tmax2  =ACFT2.MAXRATE;
Tmax3  =ACFT3.MAXRATE;

% AIRLINE OPS PARAMETERS
ISADEV=10;         % ISA DEVIATION [oC]
PAXWT=110;         % PASSENGER's WEIGHT [kg]
MAXUTIL=12;        % MAXIMUM DAILY UTILIZATION [h]
TURNAROUND=45;     % TURN AROUND TIME  [min]
AVGTIT=5;          % AVG TAXI IN TIME  [min]
AVGTOT=10;         % AVG TAXI OUT TIME [min]
ID=30;             % INFLIGHT DELAY COST [$/min]  
TO_ALLOWANCE=200;  % TAKEOFF ALLOWANCE FUEL [kg]
ARR_ALLOWANCE=100; % APPROACH ALLOWANCE FUEL [kg]
avg_ticket=110;    % AVERAGE TIKET PRICE [US$/pax]=> Ref ABEAR 2016&2017
SHARE=0.20;        % MARKET SHARE    
LFREF=0.80;        % REFERENCE LOAD FACTOR  
DISTALT=200;       % ALTERNATE AIRPORT MAXIMUM DISTANCE FROM DESTINATION AIRPORT [nm]
K1=1.1;            % TOTAL REVENUE TO TICKET REVENUE FACTOR  
K2=1.3;            % TOTAL COST TO DOC FACTOR
ACFT_Mkt_Share=0.6;% ACFT Market Share
IR=0.05;           % Interest rate  
p=15;              % life cycle (years) 
KVA=75;            % Electrical system AC Power

% NPV CALCULATION
[NPV1,CASHFLOW1,PV1,IRR1,BE1,Price1]=NPV(ACFT_Mkt_Share,IR,p,MTOW1,wS1,2,Tmax1,ediam1,NPax1,KVA);
[NPV2,CASHFLOW2,PV2,IRR2,BE2,Price2]=NPV(ACFT_Mkt_Share,IR,p,MTOW2,wS2,2,Tmax2,ediam2,NPax1,KVA);
[NPV3,CASHFLOW3,PV3,IRR3,BE3,Price3]=NPV(ACFT_Mkt_Share,IR,p,MTOW3,wS3,2,Tmax3,ediam3,NPax3,KVA);
TOTNPV=(NPV1+NPV2+NPV3)/1E9;
      
% REFERENCE DOC CALCULATION
PAYLOAD1=round(NPax1*PAXWT*LFREF);
PAYLOAD2=round(NPax2*PAXWT*LFREF);
PAYLOAD3=round(NPax3*PAXWT*LFREF);
[~,~,DOC1,CRZMACH1]=Mission5g(0,0,0,0,0,RANGE1,200,3000,2500,2500,15,15,15,ISADEV,PAYLOAD1,ACFT1,10,0); 
[~,~,DOC2,CRZMACH2]=Mission5g(0,0,0,0,0,RANGE2,200,3000,2500,2500,15,15,15,ISADEV,PAYLOAD2,ACFT2,10,0);
[~,~,DOC3,CRZMACH3]=Mission5g(0,0,0,0,0,RANGE3,200,3000,2500,2500,15,15,15,ISADEV,PAYLOAD2,ACFT3,10,0);

fprintf('\n ** REFERENCE VALUES FOR NETWORK DESIGN **');
fprintf('\n'); 
fprintf('\n CRZMACH1                 : %5.3f',CRZMACH1);
fprintf('\n CRZMACH2                 : %5.3f',CRZMACH2);
fprintf('\n CRZMACH3                 : %5.3f',CRZMACH3);
fprintf('\n RANGE1 (nm)              : %5.0f',RANGE1);
fprintf('\n RANGE2 (nm)              : %5.0f',RANGE2);
fprintf('\n RANGE3 (nm)              : %5.0f',RANGE3);
fprintf('\n DOC1   ($/nm)            : %5.2f',DOC1);
fprintf('\n DOC2   ($/nm)            : %5.2f',DOC2);
fprintf('\n DOC3   ($/nm)            : %5.2f',DOC3);
fprintf('\n PAX1                     : %5.0f',NPax1);
fprintf('\n PAX2                     : %5.0f',NPax2);
fprintf('\n PAX3                     : %5.0f',NPax3);
fprintf('\n NPV1   (x1E9 USD)        : %5.1f',NPV1/1E9);
fprintf('\n NPV2   (x1E9 USD)        : %5.1f',NPV2/1E9);
fprintf('\n NPV3   (x1E9 USD)        : %5.1f',NPV3/1E9);
fprintf('\n Price1 (x1E6 USD)        : %5.1f',Price1/1E6);
fprintf('\n Price2 (x1E6 USD)        : %5.1f',Price2/1E6);
fprintf('\n Price3 (x1E6 USD)        : %5.1f',Price3/1E6);
fprintf('\n Average fare ($)         : %5.0f',avg_ticket);
fprintf('\n Average Load Factor (pct): %5.1f',LFREF*100);
fprintf('\n Average Market Share(pct): %5.1f',SHARE*100);
fprintf('\n'); 

% NETWORK OPTIMIZATION
VPAX=[NPax1 NPax2 NPax3]';
VDOC=[DOC1 DOC2 DOC3]'; 
VRANGE=[RANGE1 RANGE2 RANGE3]';
[Airport,X,FREQ,f,LF,DIST,HDG,NPAR]=NETWORKOPT_R04f(VPAX,VDOC,VRANGE,SHARE,LFREF,avg_ticket,K1,K2);
n=size(X,2);

f
X
FREQ
DIST
HDG
NPAR 

tic

% SECTOR ANALYSIS 
for a=1:3
   
    fprintf('\n');   
    switch a
        case 1            
            fprintf('\n ** ACFT1 SECTORS **'); 
            fprintf('\n RANGE(nm): %5.0f',RANGE1);
            fprintf('\n PAX      : %5.0f',NPax1);
            ACFT=ACFT1;
            NPax=NPax1;
        case 2
            fprintf('\n ** ACFT2 SECTORS **');
            fprintf('\n RANGE(nm): %5.0f',RANGE2);
            fprintf('\n PAX      : %5.0f',NPax2);
            ACFT=ACFT2;
            NPax=NPax2;
        case 3
            fprintf('\n ** ACFT3 SECTORS **');
            fprintf('\n RANGE(nm): %5.0f',RANGE3);
            fprintf('\n PAX      : %5.0f',NPax3);
            ACFT=ACFT3;
            NPax=NPax3;
    end
    fprintf('\n');    
    fprintf('\n SECTOR    PAX LF     ZFW   FOB  TAXI  TOF   TOW    TRIP  LW    REM   DIST   HDG   CRZALT TIME  DOC  RTOW  RLW  CRZM  FREQ');
    fprintf('\n               [pct]  [kg]  [kg] [kg]  [kg]  [kg]   [kg]  [kg]  [kg]  [nm]  [deg]   [FL] [min] [$/nm][kg]  [kg]           ');
    
    %
    for i=1:n
        for j=1:n
           if i~=j;
               if X(i,j,a)~=0;
                 DISTANCE=DIST(i,j);                  
                 NPAX=round(LF(i,j)*ACFT.NPax);
                 PAYLOAD=NPAX*PAXWT;               
                 %
                 dep=Airport(i).name;
                 arr=Airport(j).name;
                 sector=string(strcat(dep,'/',arr));   
                 fprintf('\n');
                 fprintf('%s ',sector);
                 Origelev=Airport(i).elev;
                 Destelev=Airport(j).elev;
                 Altelev=Airport(i).elev;                
                 ASDA=Airport(i).ASDA;
                 LDA=Airport(j).LDA;
                 ALT_LDA=Airport(i).LDA;
                 DEP_TREF=Airport(i).Reftemp;
                 ARR_TREF=Airport(j).Reftemp;
                 ALT_TREF=Airport(i).Reftemp;               
                 %                                
                 if rvar==1
                   randTIT = -5 + 10*rand(1);  % RANDOM VARIATION FOR TAXI IN TIME (+-5 min )
                   randTOT = -3 + 6*rand(1);   % RANDOM VARIATION FOR TAXI OUT TIME(+-3 min )                  
                 else
                   randTIT=0;
                   randTOT=0;  
                 end   
                 %
                 TIT=randTIT+AVGTIT;
                 TOT=randTOT+AVGTOT;
                 TAXITIME=TIT+TOT;
                 TH=HDG(i,j);
                 THA=HDG(j,i); 
                 % Mission5g(ORIGALT,DESTALT,ALTELEV,HDG,HDG_ALT,DISTTOT,ALTDIST,ASDA,LDA,ALT_LDA,DEP_TREF,ARR_TREF,ALT_TREF,ISADEV,PAYLOAD,ACFT,TAXITIME,printflag)
                 [Wf(i,j,a),T(i,j,a),CF(i,j,a),CRZMACH(i,j,a)]=Mission5g(Origelev,Destelev,Altelev,TH,THA,DISTANCE,DISTALT,ASDA,LDA,ALT_LDA,DEP_TREF,ARR_TREF,ALT_TREF,ISADEV,PAYLOAD,ACFT,TAXITIME,1);  
                 fprintf('%3.0f ',FREQ(i,j,a));
                 T(i,j,a)=(T(i,j,a)+TIT+TOT+TURNAROUND+Airport(i).AVG_DEP_delay+Airport(j).AVG_ARR_delay)/60; 
                 Wf(i,j,a)=Wf(i,j,a)+TO_ALLOWANCE+ARR_ALLOWANCE;
               end
           end 
        end
    end     
   
  
% NETWORK RESULTS  

    TOTCOST(a)=0;
    TOTDIST(a)=0;
    TOTALFREQ(a)=0;
    TOTALPAX(a)=0; 
    TOTTIME(a)=0;
    TOTFLIGHTS(a)=0;
    AVGMACH(a)=0;
    NF(a)=0;
    % 
        for i=1:n
            for j=1:n
                if X(i,j,a)==1;
                    TOTCOST(a)=TOTCOST(a)+DIST(i,j)*CF(i,j,a)*FREQ(i,j,a)+ID*(Airport(i).AVG_DEP_delay+Airport(j).AVG_ARR_delay);
                    TOTDIST(a)=TOTDIST(a)+DIST(i,j)*FREQ(i,j,a);
                    TOTALPAX(a)=TOTALPAX(a)+round(LF(i,j)*ACFT.NPax*FREQ(i,j,a));
                    TOTTIME(a)=TOTTIME(a)+FREQ(i,j)*(T(i,j,a)+(Airport(i).AVG_DEP_delay+Airport(j).AVG_ARR_delay)+TURNAROUND)/60;
                    TOTFLIGHTS(a)=TOTFLIGHTS(a)+FREQ(i,j,a);
                    %
                    NF(a)=NF(a)+FREQ(i,j,a);
                    AVGMACH(a)=AVGMACH(a)+CRZMACH(i,j,a)*FREQ(i,j,a);
                end    
            end    
        end
    %
    AVGMACH(a)=AVGMACH(a)/NF(a);
    DOC(a)=TOTCOST(a)/TOTDIST(a);
    COST(a)=K2*TOTCOST(a);
    REV(a)=K1*TOTALPAX(a)*avg_ticket;
    PROFIT(a)=REV(a)-COST(a);
    CASK(a)=COST(a)/(TOTALPAX(a)*TOTDIST(a));
    RASK(a)=REV(a)/(TOTALPAX(a)*TOTDIST(a));
    NP(a)=RASK(a)-CASK(a);               
    NACFT(a)=TOTTIME(a)/MAXUTIL;     
    %
    fprintf('\n');
    fprintf('\n ** NETWORK RESULTS **');
    fprintf('\n'); 
    fprintf('\n Average Cruise Mach      : %10.3f',AVGMACH(a));
    fprintf('\n TOTAL DIST (nm)          : %10.2f',TOTDIST(a));
    fprintf('\n TOTAL PAX                : %10.0f',TOTALPAX(a));
    fprintf('\n TOTAL COST    ($)        : %10.2f',COST(a));
    fprintf('\n TOTAL REVENUE ($)        : %10.2f',REV(a));
    fprintf('\n TOTAL PROFIT  ($)        : %10.2f',PROFIT(a));
    fprintf('\n NDOC ($/nm)              : %6.2E',DOC(a));
    fprintf('\n NRASK ($/pax.nm)         : %6.4E',RASK(a));
    fprintf('\n NCASK ($/pax.nm)         : %6.4E',CASK(a));
    fprintf('\n NP    ($/pax.nm)         : %6.4E',NP(a));
    fprintf('\n NUM OF ACFT              : %3.0f',NACFT(a));
        
end

% TOTAL RESULTS
MCOST=0;
MTOTCOST=0;
MTOTDIST=0;
MREV    =0;
MTOTALPAX=0;
MACFT=0;

for a=1:3
   MCOST    = MCOST+COST(a);
   MTOTCOST=  MTOTCOST+TOTCOST(a);
   MTOTDIST = MTOTDIST+TOTDIST(a);
   MREV     = MREV+REV(a);
   MTOTALPAX= MTOTALPAX+TOTALPAX(a);
   MACFT    = MACFT+NACFT(a);
end
%
MDOC=MTOTCOST/MTOTDIST;
MPROFIT=MREV-MCOST;
MCASK=MCOST/(MTOTALPAX*MTOTDIST);
MRASK=MREV/ (MTOTALPAX*MTOTDIST);
MNP=MRASK-MCASK;
ND1=NPAR(1,5);
NC1=NPAR(1,6);
ND2=NPAR(2,5);
NC2=NPAR(2,6);
ND3=NPAR(3,5);
NC3=NPAR(3,6);
NN1=NPAR(3,2);
NN2=NPAR(3,2);
NN3=NPAR(3,2);
AVG_ND=(ND1+ND2+ND3)/3;
AVG_NC=(NC1+NC2+NC3)/3;
AVG_NN=(NN1+NN2+NN3)/3;
CRZMACH1=AVGMACH(1);
CRZMACH2=AVGMACH(2);
CRZMACH3=AVGMACH(3);
%
fprintf('\n');
fprintf('\n ** ALL NETWORKS RESULTS **');
fprintf('\n'); 
fprintf('\n TOTAL DIST (nm)        : %10.2f',MTOTDIST);
fprintf('\n TOTAL PAX              : %10.0f',MTOTALPAX);
fprintf('\n TOTAL COST    ($)      : %10.2f',MCOST);
fprintf('\n TOTAL REVENUE ($)      : %10.2f',MREV);
fprintf('\n TOTAL PROFIT  ($)      : %10.2f',MPROFIT);
fprintf('\n NDOC  ($/nm)           : %6.2E',MDOC);
fprintf('\n NRASK ($/pax.nm)       : %6.4E',MRASK);
fprintf('\n NCASK ($/pax.nm)       : %6.4E',MCASK);
fprintf('\n NP    ($/pax.nm)x1E-5  : %6.4E',MNP);
fprintf('\n NPV   ($/pax.nm)x1E9   : %6.4E',TOTNPV);
fprintf('\n NUM OF ACFT            : %3.0f',MACFT);
fprintf('\n AVG NETWORK DENSITY    : %5.2f',AVG_ND);
fprintf('\n AVG NETWORK CLUSTERING : %5.2f',AVG_NC);
fprintf('\n AVG NUMBER OF NODES    : %5.2f',AVG_NN);
fprintf('\n');
fprintf('\n COMPUTING TIME [sec]   : %5.1f',toc);

