/*****************************************************************************/
/*  Create a default CAS session and create SAS librefs for existing caslibs */
/*  so that they are visible in the SAS Studio Libraries tree.               */
/*****************************************************************************/

cas; 
caslib _all_ assign;


/* Fetch the file from the web site */
filename covid19 temp;
proc http
 url="https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
 method="GET"
 out=covid19;
run;

/* Tell SAS to allow "nonstandard" names */
options validvarname=any;
 
/* import to a SAS data set */
proc import
  file=covid19
  out=work.covid19 replace
  dbms=csv;
run;

proc casutil;
	load data=work.covid19 replace outcaslib="Public"
	casout="COVID19_DEATHS_GLOBAL_RAW"  ;
run;

proc cas;
table.promote caslib="Public" drop=TRUE name="COVID19_DEATHS_GLOBAL_RAW" targetlib="Public";
run;



