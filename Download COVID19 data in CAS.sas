/* Import the COVID19 Deaths data maintained by the John Hopkins Center for Systems Science and Engineering (CCSE) from the World Health Organisation (WHO) data source*/

cas mySession sessopts=(caslib=public timeout=1800 locale="en_US");
caslib _all_ assign;

%let data='https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv';
filename t temp;

proc http method='get' url=&data. out=t TIMEOUT=1;
run;

/* create temppath in order to use server side cas upload */
%let temppath = %sysfunc(quote(%sysfunc(pathname(t))));


proc cas;
   session mySession;
/* Drop the previous version of this Global table in CAS Memory before loading it */
   table.dropTable / table="COVID19_DEATHS_GLOBAL_RAW" quiet=TRUE;
run;

/* Import the csv into CAS via server side upload with GLOBAL scope as opposed to client side with PROC CASUTIL */
   upload path=&temppath.                                         
   casOut={
      name='COVID19_DEATHS_GLOBAL_RAW'
      promote=TRUE
    }
    importOptions={fileType="csv"};
run;


/* save the result in the active caslib (Public)  */
      table.save result=r /                                         
      name="COVID19_DEATHS_GLOBAL_RAW"
      table="COVID19_DEATHS_GLOBAL_RAW"
	  replace=TRUE;	
run;                
quit;