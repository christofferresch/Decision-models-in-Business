# PROJECT 3 TASK A 3A

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

same_price:								# students & seniors has the same price
	p["s"] = p["r"];

general_demand: 						# general segment demand
	Q["g"] = 120000 - 3000 * p["g"];

student_demand: 						# student segment demand
	Q["s"] = 20000 - 1250 * p["s"];

senior_demand: 							# senior segment demand
	Q["r"] = 15000 - 1400 * p["r"];

respect_demand{i in I}:					# sales cannot exceed demand
	S[i] <= Q[i];

minimum_general_quantity:				# general sales must be greater than minimum requirement
	S["g"] >= 0.2 * Cap;

minimum_others_quantity:				# student & senior sales must be greater than minimum requirement
	S["s"] + S["r"] >= 0.2 * Cap;

venue_capacity:							# sales cannot exceed venue capacity
	sum{i in I} S[i] <= Cap;