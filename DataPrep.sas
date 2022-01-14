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

