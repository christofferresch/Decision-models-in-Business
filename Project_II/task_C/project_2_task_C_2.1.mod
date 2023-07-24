# defining sets---------------------#
set I;								# Crude oils
set B;								# Components
set J;								# CDUs
set M;								# Modes
set P;								# Products
set D;								# Depots
set K;								# Markets
set T;								# Days

# defining parameters---------------#
param R			{I,B,J,M} 	>= 0;	# Amount of component b obtained from crude i in CDU j in mode m
param Cap		{J,M} 		>= 0;	# Processing capacity of crude oils in CDU j in mode m per day
param N			{B,P} 		>= 0;	# Required units of component b in product p 
param Delta		{P,K,T}		>= 0;	# Max demand for product p in market k on day t 
param S			{P}			>= 0;	# Sales price per unit product p in all markets
param Cmode		{J,M}		>= 0;	# Cost of operating CDU j in mode m per day
param Cref		{I,J,M}		>= 0;	# Cost of refining one unit crude oil i in CDU j in mode m
param Ccrude	{I,T}		>= 0;	# Cost of purchasing one unit crude oil i on day t 
param Cprod		{P}			>= 0;	# Cost of producing one unit of product p 	
param Ctra2		{D}			>= 0;	# Cost of transporting one unit of any product to depot d
param Ctra3		{D,K}		>= 0;	# Cost of transporting one unit of any product from depot d to market k
param Cinvp		{D}			>= 0;	# Daily cost of storing one unit of any product in depot d
param IzeroP	{P,D}		>= 0;	# Initial inventory of product p in depot d on day t=0
param IfinalP	{P,D}		>= 0;	# Final minimum inventory of product p at depot d on day t=12
param IzeroO	{I}			>= 0;	# Initial inventory of crude i in refinery
param IfinalO	{I}			>= 0;	# Final minimum inventory of crude I in refinery
param IzeroC	{B}			>= 0;	# Initial inventory of component b in refinery
param IfinalC	{B}			>= 0;	# Final minimum inventory of component b in refinery
param Cchange				>=0 ;	# Cost of changing modes between days
param Ctra1					>=0 ;	# Cost of transporting one unit of any component to blending
param Cinvi					>=0 ;	# Daily cost of storing one unit of any crude in the refining department
param Cinvb					>=0 ;	# Daily cost of storing one unit of any component in the refining department
param Slow					>=0 ;	# Sales price per unit lowqc
param Cinflation		   =1.1 ;	# Inflation scenario1

# defining variables----------------#
var x			{I,T}		>= 0;	# Amount of crude i to purchase and send to refinery on day t  
var y			{I,J,M,T}	>= 0;	# Amount of crude i processed using CDU j in mode m on day t
var z			{B,T}		>= 0;	# Amount of component b shipped to blending on day t 
var v			{P,D,T}		>= 0;	# Amount of product p produced and sent to depot d on day t 
var u			{P,D,K,T}	>= 0;	# Amount of product p sold to market k from depot d on day t 
var IO			{I,T}		>= 0;	# Amount of crude i in refinery storage on day t 
var IC			{B,T}		>= 0;	# Amount of component b in refinery storage on day t
var IP			{P,D,T}		>= 0;	# Amount of product p in storage at depot d on day t 
var Gmode		{J,M,T}		binary;	# Binary variable, 1 if CDU j uses mode m on day t, 0 otherwise
var Gnochange	{J,T}		binary;	# Binary variable, 1 if CDU j uses mode m on day t and on t-1
var Gchange		{J,M,T}		binary;	# Binary variable, 1 if CDU j changes mode m on day t from day t-1

# defining objective function-----------------------------------------------------------------------#
maximize profit:																					#
	sum{p in P, d in D, k in K, t in T: t>0 and t<=11} 				 S[p] * u[p,d,k,t] 				# Revenue from product sales
+	sum{i in I, b in B, j in J, m in M, t in T:t>0 and b = "lowqc"}  Slow * R[i,b,j,m]*y[i,j,m,t]	# Revenue from lowqc sales
-	sum{i in I, t in T:t>0} 										 Ccrude[i,t]*Cinflation*x[i,t] 	# Cost from crude oil purchases
-	sum{p in P, d in D, t in T:t>0} 								 Cprod[p] * v[p,d,t] 			# Cost from production
-	sum{b in B, t in T:t>0}											 Ctra1 * z[b,t] 				# Cost from transporting components to blending
-	sum{p in P, d in D, t in T:t>0}				    				 Ctra2[d] * v[p,d,t] 			# Cost from transporting products to depots
-	sum{p in P, d in D, k in K, t in T:t>0}						  	 Ctra3[d,k] * u[p,d,k,t]		# Cost from transporting produkts to markets
-	sum{i in I, t in T:t>0}											 Cinvi * IO[i,t]				# Cost from storing crude oils in refining
-	sum{b in B, t in T:t>0}											 Cinvb * IC[b,t]				# Cost from storing components in refining
-	sum{p in P, d in D, t in T:t>0}									 Cinvp[d] * IP[p,d,t]			# Cost from storing products in depots
-	sum{j in J, m in M, t in T:t>0}									 Gchange[j,m,t] * Cchange		# Cost from changing modes
-	sum{j in J, m in M, t in T:t>0}									 Cmode[j,m] * Gmode[j,m,t]		# Cost from running modes
-	sum{i in I, j in J, m in M, t in T:t>0}							 Cref[i,j,m] * y[i,j,m,t]		# Cost from refining crude oils
;

# defining constraints----------------------------------------------------------------------#
subject to
CrudBal{i in I, t in T: t > 0}:																# 1
	IO[i,t] = IO[i,t-1] + x[i,t] - sum{j in J, m in M}y[i,j,m,t];							# Crude oils balance at refinery
	
ProsCap{j in J, m in M, t in T: t > 0}:														# 2
	sum{i in I}y[i,j,m,t] <= Cap[j,m];														# processing capasity 
	
CompBalDist{b in B, t in T: t > 0 and b <> "lowqc"}:										# 3 
	IC[b,t] = IC[b,t-1] - z[b,t] + sum{i in I, j in J, m in M}R[i,b,j,m]*y[i,j,m,t];		# Component balance at refinery

RecQuan{b in B, t in T: t > 0}:																# 4
	z[b,t-1] = sum{p in P, d in D} N[b,p] * v[p,d,t];										# no storage in blending

ProdBalDep{p in P, d in D, t in T: t > 0}:													# 5
	IP[p,d,t] = IP[p,d,t-1] + v[p,d,t-1] - sum{k in K}u[p,d,k,t];							# product balance in depots

MarkDem{p in P, k in K, t in T: t > 0}:														# 6
	sum{d in D}u[p,d,k,t-1] <= Delta[p,k,t];													# Market demand
	
ModeLogic_1{i in I, j in J, m in M, t in T: t>0}:											# 7
	y[i,j,m,t] <= Cap[j,m]*Gmode[j,m,t];													# Mode variable takes value 1 if mode m is used
	
ModeLogic_2{j in J, t in T}:																# 8
	sum{m in M} Gmode[j,m,t] = 1;															# Only one mode can be used in a CDU per day

ChangeLogic{j in J, m in M, t in T: t > 0}:													# 9
	-Gmode[j,m,t-1] + Gmode[j,m,t] <= Gchange[j,m,t];										# Change variable takes value 1 if mode changes

InitCrud{i in I, t in T: t = 0}:															# 10
	IO[i,t] = IzeroO[i];																	# Initial crude storage in refinery

InitComp{b in B, t in T: t = 0}:															# 11
	IC[b,t] = IzeroC[b];																	# Initial component storage in refinery

InitProd{p in P, d in D, t in T: t = 0}:													# 12
	IP[p, d, t] = IzeroP[p,d];																# Initial product storage in depots

Init_z{b in B, t in T: t = 0}:																# 13
	z[b,t] = 0;																				# Initial shipment to blending

init_v{p in P, d in D, t in T: t = 0}:														# 14
	v[p,d,t] = 0;																			# Initial shipment to depots
	
init_u{p in P, d in D, k in K, t in T: t = 0}:												# 15
	u[p,d,k,t] = 0;																			# Initial shipment to markets

finalCrud{i in I, t in T: t = 12}:															# 16
	IO[i,t] >= IfinalO[i];																	# Final crude storage in refinery

finalComp{b in B, t in T: t = 12}:															# 17
	IC[b,t] >= IfinalC[b];																	# Final component storage in refinery

finalProd{p in P, d in D, t in T: t = 12}:													# 18
	IP[p, d, t] >= IfinalP[p,d];																# Final product storage in depots

InitMode{j in J, m in M, t in T: t = 0 and m = "Shutdown"}:									# 19
	Gmode[j,m,t] = 1;																		# Initial CDU mode is Shutdown
