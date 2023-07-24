# PROJECT 3 TASK A 3C

# defining sets
set I;

# defining parameters with non-negativity
param Cap = 55000;

# defining variables with non-negativity
var p{I} >= 0;
var Q{I} >= 0;
var S{I} >= 0;

# defining objective function
maximize revenue:
	sum{i in I} S[i] * p[i];

# defining constraints 
subject to

same_price{i in I}:						# price must be greater than 600kr
	p[i] >= 6;

general_demand: 						# general segment demand
	Q["g"] = 120000 - 3000 * p["g"];

student_demand: 						# student segment demand
	Q["s"] = 20000 - 1250 * p["s"];

senior_demand: 							# senior segment demand
	Q["r"] = 15000 - 1400 * p["r"];

respect_demand{i in I}:					# sales cannot exceed demand
	S[i] <= Q[i];

minimum_quantity{i in I}:				# sales must be greater than minimum requirement
	S[i] >= 0.05 * Cap;

venue_capacity:							# sales cannot exceed venue capacity
	sum{i in I} S[i] <= Cap;

double_price_1:							# 1-6: segment prices cannot be greater than double the price in any other segment
	p["g"] <= 2*p["s"];
	
double_price_2:
	p["g"] <= 2*p["r"];
	
double_price_3:
	p["s"] <= 2*p["g"];
	
double_price_4:
	p["s"] <= 2*p["r"];
	
double_price_5:
	p["r"] <= 2*p["g"];
	
double_price_6:
	p["r"] <= 2*p["s"];