# BAN402 - Assignment 1 - task B

# defining sets
set CRUD;#------------------------------------# crude oil
set GGAS;									  # gas
set MARK;									  # market
set CONT;									  # contents (octane & sulfur)

# defining parameters with non-negativity
param A{CRUD} >= 0;#--------------------------# barrels of crude oil i available
param D{GGAS, MARK} >= 0;					  # demand of gas j in market m 
param S{GGAS, MARK} >= 0;					  # sale price of gas j in market m
param P{CRUD} >= 0;							  # purchase price crude oil i
param C{GGAS} >= 0;							  # production cost of one barrel of gas j 
param R{CRUD, CONT} >= 0;					  # units of attribute b per barrel of crude i
param L{GGAS, CONT} >= 0;					  # minimum units of attribute b per barrel of gas j
param H{GGAS, CONT} >= 0;					  # maximum allowed units of attribute b per barrel of gas j
param W{GGAS} >= 0;							  # workhours per barrel of gas j 
param T = 520;								  # available workhours

# defining variables with non-negativity
var u{CRUD} >= 0;#----------------------------# amount of crude oil purchased	
var w{GGAS} >= 0;							  # amount of gas j produced
var r{CRUD,GGAS} >= 0;						  # amount of crude oil i in gas j
var v{GGAS, MARK} >= 0;						  # amount of gas j sent to market m

# defining objective function
maximize z:#------------------------------------------# maximize profit
	sum{j in GGAS, m in MARK} v[j,m] * S[j,m] -		  # revenue
	sum{i in CRUD} u[i] * P[i] -					  # purchasing costs
	sum{j in GGAS} w[j] * C[j];						  # production costs

# defining constraints 
subject to

MatCont{i in CRUD}:#--------------------------------- # barrels of crude oil used
	sum{j in GGAS}r[i,j] = u[i];					  # equal to amount bought

ProdCont{j in GGAS}:								  # barrels of crude oil used
	 sum{i in CRUD}r[i,j] = w[j];					  # equal to barrels of gas produced
	
SellCont{j in GGAS}: 								  # barrels of gas sold
	sum{m in MARK} v[j,m] = w[j];					  # equal to barrels of gas produced

RawAvail{i in CRUD}:								  # barrels of crude oil bought 
	u[i] <= A[i];									  # less or equal to availability

WorkAvail:											  # workhours used
	sum{j in GGAS} (w[j] * W[j]) <= T;				  # less or equal to availability

MarkDem{j in GGAS, m in MARK}:						  # barrels of gas sold in each market
	v[j,m] >= D[j,m];							 	  # greater or equal to demand

QualMin{j in GGAS,b in CONT}:						  # minimum amount of each attribute
	L[j, b] * w[j] <= sum{i in CRUD} R[i,b] * r[i,j]; # less or equal to amount in final product

QualMax{j in GGAS,b in CONT}:						  # maximum amount of each attribute
	H[j, b] * w[j] >= sum{i in CRUD} R[i,b] * r[i,j]; # greater or equal to amount in final product

	