clear

log using did_simulate_T2_exponential_nocov_20211229_1, text replace

set seed 123

global nobs = 1000
global tobs = 2
global iter = 1000

set obs $nobs
gen id =_n
expand $tobs
bysort id: gen year = _n + 2000
gen f02 = year == 2002

gen c = sqrt(2)*rnormal(0,1)
bysort id: replace c = c[1]

gen e0 = sqrt(2)*rnormal(0,1)
gen e1 = sqrt(2)*rnormal(0,1)

gen u0 = (c + e0)/2
gen u1 = (c + e1)/2


gen trt = -.3 + rlogistic(0,1) > 0
bysort id: gen d = trt[1]
drop trt

gen y0star = .4*f02 - 2*d + u0
gen y1star = y0star
replace y1star = .2 + y0star + u1 if f02

gen y0 = rpoisson(exp(y0star))
gen y1 = rpoisson(exp(y1star))

sum y0 y1 d

gen te_i = y1 - y0 if f02
sum te_i if d & f02

* Observed outcome:
gen y = (1 - d)*y0 + d*y1

* Generate time-varying treatment indicator for common intervention:
gen w = d*f02
	
xtset id year

* Linear model, POLS:

reg y c.d#c.f02 f02 d, vce(cluster id)
	
* Exponential mean, Poisson QMLE:

poisson y i.w#c.d#c.f02 f02 d, vce(cluster id) noomitted
margins, dydx(w) at(d = 1 f02 = 1) noestimcheck post

capture program drop did_2

program did_2, rclass
drop _all

set obs $nobs
gen id =_n
expand $tobs

bysort id: gen year = _n + 2000
gen f02 = year == 2002

xtset id year

gen c = sqrt(2)*rnormal(0,1)
bysort id: replace c = c[1]

gen e0 = sqrt(2)*rnormal(0,1)
gen e1 = sqrt(2)*rnormal(0,1)

gen u0 = (c + e0)/2
gen u1 = (c + e1)/2

gen trt = -.4 + rlogistic(0,1) > 0
bysort id: gen d = trt[1]
drop trt

gen y0star = .4*f02 - 2*d + u0
gen y1star = y0star
replace y1star = .2 + y0star + u1 if f02

gen y0 = rpoisson(exp(y0star))
gen y1 = rpoisson(exp(y1star))

sum y0
return scalar y0_mean = r(mean)
sum y1
return scalar y1_mean = r(mean)

sum d
return scalar d_p = r(mean)

gen te = y1 - y0 if f02
sum te if d & f02
return scalar att = r(mean)

* Observed outcome:
	gen y = (1 - d)*y0 + d*y1

* Generate time-varying treatment indicator for common intervention:
	gen w = d*f02
	
* Linear, POLS:
	reg y c.d#c.f02 f02 d
	return scalar att_linear = _b[c.d#c.f02]
	
* Exponential, pooled QMLE:
	poisson y i.w#c.d#c.f02 f02 d, noomitted
	margins, dydx(w) at(d = 1 f02 = 1) noestimcheck post
	return scalar att_poisson = _b[1.w]

end

set seed 123

simulate r(att) r(att_linear) r(att_poisson) r(d_p) r(y0_mean) r(y1_mean), reps($iter): did_2

sum, sep(3)
	
log close

