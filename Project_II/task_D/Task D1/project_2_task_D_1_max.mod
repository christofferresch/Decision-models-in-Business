
#### Linear programming model ####

set D ordered; # Set of days
set M ordered; # Set of months
set H ordered; # Set of hours

param c{M, D, H}; # Energy price at month m, day d and hour h
param a{M, D, H}; # Charging availability at month m, day d at hour h
param v{M, D, H}; # Energy usage at month m, day d at hour h


var x{m in M, d in D, h in H} >= 0; # Charging amount at month m, during day d at time h
var b{m in M, d in D, h in H} >= 0; # State of charge at month m, day d and time h

maximize z:
	sum{m in M, d in D, h in H}c[m,d,h]*x[m,d,h];

# (1) Defining maximum charging rate at home charger	
subject to MaxChargeRate{m in M, d in D, h in H}:
	x[m,d,h] <= a[m,d,h];
	
# (2) Defining maximum battery capacity
subject to BatteryMax{m in M, d in D, h in H}:
	b[m,d,h] <= 64;
	
# (3) Preventing range anxiety with minimum battery charge
subject to BatteryMin{m in M, d in D, h in H}:
	b[m,d,h] >= 12.8;

# (4) Balancing battery level between hours
subject to PeriodsChargeBalanceHours{m in M, d in D, h in H:h>1}:
	b[m,d,h] = b[m,d,h-1] + x[m,d,h] - v[m,d,h];

# (5) Balancing battery level between days
subject to PeriodsChargeBalanceDays{m in M, d in D:d>1}:
	b[m,d,1] = b[m,d-1,24] + x[m,d,1] - v[m,d,1];

# (6) Balancing battery level between months
subject to	
# Between July and August
InitDay32:
	b["August",1,1] = b["July",31,24] + x["August",1,1] - v["August",1,1];
# Between August and September	
InitDay62:
	b["September",1,1] = b["August",31,24] + x["September",1,1]- v["September",1,1]; 

# (7) Setting state of charge constraints
subject to 
# Setting inital state of charge
InitialJul:
	b["July",1,1] = 51.2 + x["July",1,1];
# Setting state of charge at end period	
InitDayEND:
	b["September",31,24] = 51.2;

	
	

	
