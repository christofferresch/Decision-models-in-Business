# BAN402 - Assignment 1 - task C

# defining sets
set REGI;#------------------------------------- # regions
set PORT;										# ports
set MARK;										# markets

# defining parameters with non-negativity
param s{REGI} >= 0;#----------------------------# available supply in the regions
param d{MARK} >= 0; 	 						# amounts demanded in the markets
param c{REGI,MARK} >= 0;   						# cost per 1000kg from region to market
param e{REGI,PORT} >= 0;						# cost per 1000kg from region to port
param g{PORT,MARK} >= 0;						# cost per 1000kg from port to market

# defining variables with non-negativity
var x{REGI,MARK} >= 0;#-------------------------# quantity from region to market
var y{REGI,PORT} >= 0;							# quantity from region to port
var w{PORT,MARK} >= 0;							# quantity from port to market

# defining objective function
minimize z:#------------------------------------# minimize cost
   sum {i in REGI, j in MARK} c[i,j] * x[i,j]+  # cost of transport from region to market
   sum {i in REGI, k in PORT} e[i,k] * y[i,k]+  # cost of transport from region to port
   sum {k in PORT, j in MARK} g[k,j] * w[k,j];  # cost of transport from port to market

# defining constraints   
subject to

SupplyCap {i in REGI}:#--------------------------------------# total quantity sent from region
   sum {j in MARK} x[i,j] +  sum {k in PORT} y[i,k] <= s[i]; # less or equal to available supply

TransShip {k in PORT}:#--------------------------------------# total quantity recieved in port
   sum {i in REGI} y[i,k] -  sum {j in MARK} w[k,j] = 0;     # sent to markets (no storage)

MarkDem {j in MARK}:#----------------------------------------# total quantity sent to markets
   sum {i in REGI} x[i,j] +  sum {k in PORT} w[k,j] = d[j];  # equal to demand (strict)
