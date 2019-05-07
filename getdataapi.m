function datadt=getdatahtml(stdate,endate,stname)
% Written by Sequoia Alba 2009. Updated July 2012

% getgatahtml.m retrieves data from the tidesandcurrents.noaa.gov website.
% stdate and endate should be in the format: yyyymmdd and the station name
% should be in the format like: <port angeles, wa> it is case insensitive
% it outputs a matrix in the form [Date Pred WaterLev DetidedWL] the date
% is in matlab datenumber format. Function is dependent on NOAAstats.mat
% which has NOAA station names and numbers in table format.

clear datadt
load NOAAstats.mat

% find station number from lookup matrix NOAAstats.mat
numindx=find(strcmpi(statnames,stname));
stnum=statnums(numindx);
stname = strrep(stname,' ', '+');                   % replace spaces with +
stdate=num2str(stdate);
endate=num2str(endate);
% start and end date to matlab date numbers
st=datenum(stdate,'yyyymmdd');
en=datenum(endate,'yyyymmdd');
% how many years are spanned?
yrs=(en-st)/365;
datadt=zeros(0,4);
% if it is greater than one year, go by year, building up to full range
while yrs>1
 % define start and end date within while loop
    stdate=datestr(st,'yyyymmdd');
    endate=datestr(st+365,'yyyymmdd');
 %create a unique query address from varialble
ap1='https://tidesandcurrents.noaa.gov/api/datagetter?begin_date=';
ap2=stdate;     % start date
%begin_date=20120101&end_date=20120102
ap3='&end_date=';
ap4=endate;     % end date
ap5='station=';
ap6=strcat(num2str(stnum),'+'); %station number from lookup matrix

% ap7 contains the information on what format, datum, units and time format
% according to the following:
% (1) FORMAT   
% product=
%               water_level	-  Preliminary or verified water levels, depending on availability.
%               air_temperature	-  Air temperature as measured at the station.
%               water_temperature . -	Water temperature as measured at the station.
%               wind  -	Wind speed, direction, and gusts as measured at the station.
%               air_pressure  -	Barometric pressure as measured at the station.
%               air_gap  -	Air Gap (distance between a bridge and the water's surface) at the station.
%               conductivity  -	The water's conductivity as measured at the station.
%               visibility  -	Visibility from the station's visibility sensor. A measure of atmospheric clarity.
%               humidity -	Relative humidity as measured at the station.
%               salinity  -	Salinity and specific gravity data for the station.
%               hourly_height  -	Verified hourly height water level data for the station.
%               high_low  -	Verified high/low water level data for the station.
%               daily_mean	-  Verified daily mean water level data for the station.
%               monthly_mean	-  Verified monthly mean water level data for the station.
%               one_minute_water_level	-  One minute water level data for the station.
%               predictions	-  6 minute predictions water level data for the station.
%               datums	-  datums data for the stations.
%               currents	-  Currents data for currents stations.
% (2) DATUM 
% datum=
%     
%               CRD     Columbia River Datum
%               IGLD	International Great Lakes Datum
%               LWD     Great Lakes Low Water Datum (Chart Datum)
%               MHHW	Mean Higher High Water
%               MHW     Mean High Water
%               MTL     Mean Tide Level
%               MSL     Mean Sea Level
%               MLW     Mean Low Water
%               MLLW	Mean Lower Low Water
%               NAVD	North American Vertical Datum
%               STND	Station Datum
% (3) UNITS 
% units=
%               metric	Metric (Celsius, meters, cm/s) units
%               english	English (fahrenheit, feet, knots) units
% (4) Time Format
% time_zone=
%               gmt     Greenwich Mean Time
%               lst     Local Standard Time. The time local to the requested station.
%               lst_ldt	Local Standard/Local Daylight Time. The time local to the requested station.
% in this case it's Hourly, relative to Station Datum, in Meters, and LST 
ap7='&product=hourly_height&datum=STND&units=metric&time_zone=lst';


% ap8 contains information about the orginization requesting information
% and the format, in this case xml but json and csv are also possible
ap8='&application=University_of_Oregon&format=xml';

urladdress=strcat(ap1,ap2,ap3,ap4,ap5,ap6,ap7,ap8);
%read in URL from html
u=urlread(urladdress);
whos u;
c=findstr(u,'------- -------- ----- ------- -------'); %look beginning of data
d=textscan(u(c+38:end),'%n %s %s %n %n');              %read in data first two are date and time
                                                    
% have to turn the date and time into matlab date vector
ndate=strcat(d{2},d{3});                            
daten=datenum(ndate,'yyyymmddHH:MM');
% want to make sure that data is in the right order
order=findstr(u,'Station Date');    %find data labels line
dorder=(u(order:order+38'));
predloc=findstr(dorder,'Pred ');    %location of prediction col
wlloc=findstr(dorder,'Vrfy ');      %location of water levels col

% check order and arrange data to be: [Date Pred WaterLev]
if (predloc < wlloc)
    data=[daten,d{4},d{5}];
else
    data=[daten,d{5},d{4}];
end;
% add 4th col which will be detided wl
dtide=data(:,3)-data(:,2);      %waterlev-predictions
datat=[data, dtide];            %should now be: [date pred wl dtidedwl]
datadt=[datadt;datat];
st=datenum(endate,'yyyymmdd')+1;
   yrs=(en-st)/365;
end
% this deals with the last chunk of data that is not a complete year it is
% otherwise the same as above
stdate=datestr(st,'yyyymmdd');
    endate=datestr(en,'yyyymmdd');
ap1='http://tidesandcurrents.noaa.gov/data_menu.shtml?bdate=';
ap2=stdate;
ap3='&edate=';
ap4=endate;

ap5='&wl_sensor_hist=W2&relative=&datum=0&unit=0&shift=s&stn=';
ap6=strcat(num2str(stnum),'+');
ap7=stname;

ap8='&type=Historic+Tide+Data&format=View+Data';
urladdress=strcat(ap1,ap2,ap3,ap4,ap5,ap6,ap7,ap8);
%%read in URL from html
u=urlread(urladdress);
c=findstr(u,'------- -------- ----- ------- -------'); %look beginning of data
d=textscan(u(c+38:end),'%n %s %s %n %n');      %read in data first two are 
                                                    % date and time
% have to turn the date and time into matlab date vector
ndate=strcat(d{2},d{3});                           
daten=datenum(ndate,'yyyymmddHH:MM');
% want to make sure that data is in the right order
order=findstr(u,'Station Date');    %find data labels line
dorder=(u(order:order+38'));
predloc=findstr(dorder,'Pred ');    %location of prediction col
wlloc=findstr(dorder,'Vrfy ');      %location of water levels col

% check order and arrange data to be: [Date Pred WaterLev]
if (predloc < wlloc)
    data=[daten,d{4},d{5}];
else
    data=[daten,d{5},d{4}];
end
% add 4th col which will be detided wl
dtide=data(:,3)-data(:,2);      %waterlev-predictions
datat=[data, dtide];       %should now be: [date pred wl dtidedwl]
datadt=[datadt;datat];
return
%view-source:http://tidesandcurrents.noaa.gov/data_menu.shtml?
%bdate=20100809&edate=20100810&wl_sensor_hist=W1&relative=&datum=6
%&unit=0&shift=s&stn=9444900+Port+Townsend,+WA&type=Historic+Tide+Data&format=View+Data