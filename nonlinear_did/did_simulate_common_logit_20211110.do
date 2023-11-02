clear

log using did_common_binary_20211110, text replace

set seed 123

global nobs = 1000
global tobs = 6
global iter = 1000

set obs $nobs
gen id =_n
expand $tobs

bysort id: gen year =_n + 2000
gen f01 = year == 2001
gen f02 = year == 2002
gen f03 = year == 2003
gen f04 = year == 2004
gen f05 = year == 2005
gen f06 = year == 2006

gen x0 = rgamma(1,1)
egen x = mean(x0), by(id)

gen c = sqrt(2)*rnormal(0,1)
* gen c = rnormal(0,1)
bysort id: replace c = c[1]


* Add serial correlation in future.
gen e0 = sqrt(2)*rnormal(0,1)
gen e1 = sqrt(2)*rnormal(0,1)

/*
* Normal with unobserved effect:
gen u0 = (c + e0)/2
gen u1 = (c + e1)/2
*/

gen u0 = logit(normal((c + e0)/2))/sqrt(3)
gen u1 = logit(normal((c + e1)/2))/sqrt(3)

/*
gen u0 = rlogistic()
gen u1 = rlogistic()
*/

/*
sum r0 r1 u0 u1
corr r0 r1
corr u0 u1
*/

gen trt = -.5 + 2*(x - 1) + rlogistic(0,1) > 0
bysort id: gen d = trt[1]
drop trt

gen y0star = .4*f04 + .5*f05 + .6*f06 + (x - 1)/2 - 2*d + u0
gen y1star = y0star
replace y1star = .4*f04 + .5*f05 + .6*f06 + (x - 1)/2 - 2*d ///
	+ .5 + .1*f05 + .2*f06 + u1 if year >= 2004

gen y0 = y0star > 0
gen y1 = y1star > 0

tab y0
tab y1

sum x if ~d
sum x if d
gen x_dm = x - r(mean)
	
gen te_i = y1 - y0 if year >= 2004
sum te_i if d & f04
sum te_i if d & f05
sum te_i if d & f06
	
* Observed outcome:
gen y = (1 - d)*y0 + d*y1

* Generate time-varying treatment indicator for common intervention:
gen w = d*(f04 + f05 + f06)

* save did_common_6_binary, replace

* Linear model, without and with adjusting standard errors:

reg y c.d#c.f04 c.d#c.f05 c.d#c.f06 ///
	c.d#c.f04#c.x_dm c.d#c.f05#c.x_dm c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x, vce(cluster id)

reg y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck
	
* Logit:

logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck post
qui logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck post
qui logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck post
	

* Callaway and Sant'Anna:

gen first_treat = 0
replace first_treat = 2004 if d
csdid y x, ivar(id) time(year) gvar(first_treat)
csdid y x, ivar(id) time(year) gvar(first_treat) method(reg)

/*
* BJS imputation:
replace first_treat = . if first_treat == 0
replace first_treat = 2004 if d
did_imputation y id year first_treat, unitc(x) timec(x) allhorizon pretrend(2)
	
test (pre1 = 0) (pre2 = 0)
*/


capture program drop did_common

program did_common, rclass
drop _all

set obs $nobs
gen id =_n
expand $tobs

bysort id: gen year =_n + 2000
gen f01 = year == 2001
gen f02 = year == 2002
gen f03 = year == 2003
gen f04 = year == 2004
gen f05 = year == 2005
gen f06 = year == 2006

gen x0 = rgamma(1,1)
egen x = mean(x0), by(id)


gen c = sqrt(2)*rnormal(0,1)
* gen c = rnormal(0,1)
bysort id: replace c = c[1]

* Might add serial correlation in future.
gen e0 = sqrt(2)*rnormal(0,1)
gen e1 = sqrt(2)*rnormal(0,1)

* Logit with unobserved effect:
gen u0 = logit(normal((c + e0)/2))/sqrt(3)
gen u1 = logit(normal((c + e1)/2))/sqrt(3)


/*
* Probit with unobserved effect:
gen u0 = (c + e0)/2
gen u1 = (c + e1)/2
*/

/*
* Independent logistic:
gen u0 = rlogistic()
gen u1 = rlogistic()
*/

gen trt = -.5 + 2*(x - 1) + rlogistic(0,1) > 0
bysort id: gen d = trt[1]
drop trt

/*
gen y0star = .4*f04 + .5*f05 + .6*f06 + (x - 1)/2 - 2*d + u0
gen y1star = y0star
replace y1star = .4*f04 + .5*f05 + .6*f06 + (x - 1)/2 - 2*d ///
	+ 1 + .1*f05 + .2*f06 + u1 if year >= 2004
*/
	
gen y0star = .4*f04 + .5*f05 + .6*f06 + (x - 1)/2 - 2*d + u0
gen y1star = y0star
replace y1star = .4*f04 + .5*f05 + .6*f06 + (x - 1)/2 - 2*d ///
	+ .5 + .1*f05 + .2*f06 + u1 if year >= 2004

gen y0 = y0star > 0
gen y1 = y1star > 0

sum y0
return scalar y0_mean = r(mean)
sum y1
return scalar y1_mean = r(mean)

sum d
return scalar d_p = r(mean)
sum x if ~d
return scalar mux0 = r(mean)
sum x if d
return scalar mux1 = r(mean)
gen x_dm = x - r(mean)

gen te_i = y1 - y0 if year >= 2004
sum te_i if d & f04
return scalar att_4 = r(mean)
sum te_i if d & f05
return scalar att_5 = r(mean)
sum te_i if d & f06
return scalar att_6 = r(mean)

* Observed outcome:
gen y = (1 - d)*y0 + d*y1

* Generate time-varying treatment indicator for common intervention:
gen w = d*(f04 + f05 + f06)
	
xtset id year

* linear:

reg y c.d#c.f04 c.d#c.f05 c.d#c.f06 ///
	c.d#c.f04#c.x_dm i.w#c.d#c.f05#c.x_dm i.w#c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x

	return scalar att_4_linear = _b[c.d#c.f04]
	return scalar att_5_linear = _b[c.d#c.f05]
	return scalar att_6_linear = _b[c.d#c.f06]
	return scalar rsq = e(r2)
	
* logit/probit:

logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted
estimates store beta
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck post
return scalar att_4_logit = _b[1.w]
estimates restore beta
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck post
return scalar att_5_logit = _b[1.w]	
estimates restore beta
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck post
return scalar att_6_logit = _b[1.w]


* Callaway and Sant'Anna:

	gen first_treat = 0
	replace first_treat = 2004 if d
	csdid y x, ivar(id) time(year) gvar(first_treat) reps(0)
	return scalar att_4_cs = _b[g2004:t_2003_2004]
	return scalar att_5_cs = _b[g2004:t_2003_2005]
	return scalar att_6_cs = _b[g2004:t_2003_2006]
		
end

set seed 123


simulate r(att_4) r(att_5) r(att_6) ///
	r(att_4_linear) r(att_5_linear) r(att_6_linear) ///
	r(att_4_logit) r(att_5_logit) r(att_6_logit) ///
	r(att_4_cs) r(att_5_cs) r(att_6_cs) ///
	r(rsq) r(d_p) r(y0_mean) r(y1_mean) r(mux0) r(mux1), reps($iter): did_common
	
sum, sep(3)
	
log close

