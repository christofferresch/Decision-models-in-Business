
#### Model for processing fish with new technology at facilities

reset;

# Defining variables
var F1>=0;
var F2>=0;
var F3>=0;

# Defining objective function
minimize total_cost: 30*F1 + 20*F2 + 40*F3;

# Defining constraints
subject to
pollutant1: 0.10*F1 + 0.20*F2 + 0.40*F3 >= 25;
pollutant2: 0.45*F1 + 0.25*F2 + 0.30*F3 >= 35;

# Choosing solver
option solver cplex;

option presolve 0; #turning off presolve procedures to perform sensitivity analysis
option cplex_options 'sensitivity'; #to allow using sensitivity analysis commands

# Asking it to solve
solve;

# Displaying variables
display total_cost, F1, F2, F3 > report_sensitivity.txt;

# SENSITIVITY ANALYSIS 

#Shadow prices
display pollutant1,pollutant1.down,pollutant1.current,pollutant1.up  > report_sensitivity.txt;
display pollutant2,pollutant2.down,pollutant2.current,pollutant2.up  > report_sensitivity.txt;
#Allowable range
display F1.down,F1.current,F1.up  > report_sensitivity.txt;
display F2.down,F2.current,F2.up  > report_sensitivity.txt;
display F3.down,F3.current,F3.up  > report_sensitivity.txt;
#Reduced costs
display F1.rc,F2.rc,F3.rc  > report_sensitivity.txt;
display total_cost, F1, F2, F3

