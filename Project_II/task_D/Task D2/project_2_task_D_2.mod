
#### Linear programming model ####

set D ordered; # Set of days
set M ordered; # Set of months
set H ordered; # Set of hours

param c{M, D, H}; # Energy price at month m, day d at hour h
param a{M, D, H}; # Available charging rate at month m, day d at hour h
param v{M, D, H}; # Energy usage at month m, day d at hour h
param k;


var x{m in M, d in D, h in H} >= 0; # Charging amount at month m, during day d at time h
var b{m in M, d in D, h in H} >= 0; # State of charge at month m, day d and time h
var w{m in M,d in D,h in H} >=0;	
var o{m in M,d in D,h in H} binary; # 1 if departure from home at that month m, day d and hour h, 0 otherwise
var i{m in M,d in D,h in H} binary; # 1 if arrival to home at that month m, day d and hour h, 0 otherwise
var r{m in M,d in D,h in H} binary; # 1 if at recreational between driving
var z{m in M,d in D,h in H} binary; # 1 if not departing, at recreational or arriving

minimize cost:
	sum{m in M, d in D, h in H}c[m,d,h]*x[m,d,h];


##-------------- Constraints for integer problem -------------------

subject to	
	
Init1{m in M, d in 3..31 by 7, h in H : d>0 and h=12 and m = "July"}:
	o[m,d,h] = 1;
	
Init2{m in M, d in 7..31 by 7, h in H : d>0 and h=12 and m = "August"}:
	o[m,d,h] = 1;
	
Init3{m in M, d in 4..31 by 7, h in H : d>0 and h=12 and m = "September"}:
	o[m,d,h] = 1;


Logic11{m in M, d in 3..31 by 7, h in H : d>0 and h<24 and m = "July"}:
	r[m,d,h] - r[m,d,h+1] -1 >= -1 - o[m,d,h];
	
Logic12{m in M, d in 7..31 by 7, h in H : d>0 and h<24 and m = "August"}:
	r[m,d,h] - r[m,d,h+1] -1 >= -1 - o[m,d,h];
	
Logic13{m in M, d in 4..31 by 7, h in H : d>0 and h<24 and m = "September"}:
	r[m,d,h] - r[m,d,h+1] -1 >= -1 - o[m,d,h];
				
	
Logic21{m in M, d in 3..31 by 7, h in H : d>0 and h>1 and m = "July"}:
	r[m,d,h] - r[m,d,h-1] -1 >= -1 - i[m,d,h];
	
Logic22{m in M, d in 7..31 by 7, h in H : d>0 and h>1 and m = "August"}:
	r[m,d,h] - r[m,d,h-1] -1 >= -1 - i[m,d,h];
	
Logic23{m in M, d in 4..31 by 7, h in H : d>0 and h>1 and m = "September"}:
	r[m,d,h] - r[m,d,h-1] -1 >= -1 - i[m,d,h];
	
	

Logic31{m in M, d in 3..31 by 7, h in H : d>0 and h>1 and h<24 and m = "July"}:
	r[m,d,h] = o[m,d,h-1] + i[m,d,h+1];
	
Logic32{m in M, d in 7..31 by 7, h in H : d>0 and h>1 and h<24 and m = "August"}:
	r[m,d,h] = o[m,d,h-1] + i[m,d,h+1];
	
Logic33{m in M, d in 4..31 by 7, h in H : d>0 and h>1 and h<24 and m = "September"}:
	r[m,d,h] = o[m,d,h-1] + i[m,d,h+1];
	
			

Logic4{m in M, d in D, h in H : d>0 and h>=1 and h<=24}:
	z[m,d,h] = 1 - o[m,d,h] - r[m,d,h] - i[m,d,h];





	
## --------------- Constraints for linear problem ------------------	

# Defining maximum charging rate at home charger	
subject to MaxChargeRate{m in M, d in D, h in H}:
	x[m,d,h] <= a[m,d,h]*z[m,d,h];
	
# Defining maximum battery capacity
BatteryMax{m in M, d in D, h in H}:
	b[m,d,h] <= 64;

	
# Preventing range anxiety with minimum battery charge
BatteryMin{m in M, d in D, h in H}:
	b[m,d,h] >= 12.8;

# Balancing battery level between hours
PeriodsChargeBalanceHours{m in M, d in D, h in H:h>1}:
	b[m,d,h] = b[m,d,h-1] + x[m,d,h] - v[m,d,h] - o[m,d,h]*k - i[m,d,h]*k; 

# Balancing battery level between days
PeriodsChargeBalanceDays{m in M, d in D:d>1}:
	b[m,d,1] = b[m,d-1,24] + x[m,d,1] - v[m,d,1]- o[m,d,1]*k - i[m,d,1]*k;

# Balancing battery level between months

# Between July and August
InitDay32:
	b["August",1,1] = b["July",31,24] + x["August",1,1] - v["August",1,1];
# Between August and September	
InitDay62:
	b["September",1,1] = b["August",31,24] + x["September",1,1]- v["September",1,1]; 

# Setting state of charge constraints

# Setting inital state of charge
InitialJul:
	b["July",1,1] = 51.2 + x["July",1,1];
# Setting state of charge at end period	
InitDayEND:
	b["September",31,1] = 51.2;

		
		

	
