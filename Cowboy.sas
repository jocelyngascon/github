/*This SAS file creates a comboy hat graphic using proc g3d */

goptions cback=black colors=(white cyan red conflict yellow);


/* DATA step to create the "hat" data */
data hat; 
 do x = -5 to 5 by .25;
  do y = -5 to 5 by .25;
   z = sin(sqrt(y*y + x*x));
   output;
  end;
 end;
run;
title1 c=white f=swiss 'Wifi Antenna Signal Level @1.5m from the floor';
title2 h=2 color=bibg angle=90 'Relative Strength';

/* plot the 3d graph change 2*/
proc g3d data=hat;
plot y*x=z / ctop=blueviolet ctext=white;
run; 