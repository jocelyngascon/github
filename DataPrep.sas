/* Simple SAS program with Proc SQL queries and datasteps followed by */
/* frequently used statistical analysis SAS Procedures                */
/* Demo by Jocelyn.Gascon-Giroux@sas.com 514-918-7397                 */


libname source '~/Data/source';
libname target '~/Data/target';


/*  Traitement des données  */

data target.customers; 
 set source.customers;
run;

proc sql; 
 create table target.indirect as 
  select * from source.customers 
   where Sales_channel='Indirect';
quit;

data target.direct; 
 set source.customers;
 if sales_channel ne 'Indirect';
run;

data target.combined;
 merge target.indirect target.direct;
run;

/***************************/

/*** Analyze categorical variables ***/
title "Frequencies for Categorical Variables";

proc freq data=TARGET.COMBINED;
	tables Region Sales_channel credit_level / plots=(freqplot);
run;

/*** Analyze numeric variables ***/
title "Descriptive Statistics for Numeric Variables";

proc means data=TARGET.COMBINED n nmiss min mean median max std;
	var Age Est_HH_Income connections_LT cs_med_H_value cs_pct_H_owner 
		store_visits_y last_discount_amt avg_order_value_3y purchases_3yr 
		purchases_6y purchases_9yr;
run;

title;

proc univariate data=TARGET.COMBINED noprint;
	histogram Age Est_HH_Income connections_LT cs_med_H_value cs_pct_H_owner 
		store_visits_y last_discount_amt avg_order_value_3y purchases_3yr 
		purchases_6y purchases_9yr;
run;

