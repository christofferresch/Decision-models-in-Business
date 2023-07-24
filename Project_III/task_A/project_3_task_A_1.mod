# PROJECT 3 TASK A1

# defining sets
set I;

# defining parameters with non-negativity
param Cap = 55000;

# defining variables with non-negativity
var Q{I} >= 0;
var p{I} >= 0;
var S{I} >= 0;

# defining objective function
maximize revenue:
	sum{i in I} S[i] * p[i];

# defining constraints 
subject to

same_price:								# general & students has the same price
	p["g"] = p["s"];					

general_demand: 						# general segment demand
	Q["g"] = 120000 - 3000 * p["g"];	

student_demand: 						# student segment demand
	Q["s"] = 20000 - 1250 * p["s"];		

respect_demand{i in I}:					# sales cannot exceed demand
	S[i] <= Q[i];

minimum_quantity{i in I}:				# sales must be greater than minimum requirement
	S[i] >= 0.2 * Cap;

venue_capacity:							# sales cannot exceed venue capacity
	sum{i in I} S[i] <= Cap;



