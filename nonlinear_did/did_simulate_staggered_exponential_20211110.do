clear

log using did_staggered_poisson_20211110, text replace

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

gen c = rnormal(0,1)
bysort id: replace c = c[1]

* Add serial correlation in future.
gen u = rnormal(0,1)

* Generate treatment cohorts:

gen trt = -.5 + x/3 + rnormal(0,1) > 0
egen trt_sum = sum(trt), by(id)
gen dinf = trt_sum <= 2
gen d4 = trt_sum == 3
gen d5 = trt_sum == 4
gen d6 = trt_sum >= 5

drop trt trt_sum

* Generate potential outcomes with common trends imposed.
* Also common effect across time.

/*
gen yinfstar = .2 + .2*f02 + .3*f03 + .4*f04 + .5*f05 + .6*f06 + x/5 + c - (d4 + d5 + d6) + u
gen yinf = rpoisson(1)*exp(yinfstar)
gen y4 = yinf
replace y4 = rpoisson(1)*exp(yinfstar + .1 + (x - 1)/5 + .2*f05 + .3*f06 + rnormal(0,1)) if year >= 2004
gen y5 = yinf
replace y5 = rpoisson(1)*exp(yinfstar + .3 + (x - 1)/5 + .2*f06 + rnormal(0,1)) if year >= 2005
gen y6 = yinf
replace y6 = rpoisson(1)*exp(yinfstar + .2 + (x - 1)/5 + rnormal(0,1)) if year >= 2006
*/


/*
gen yinfstar = .2 + .2*f02 + .3*f03 + .4*f04 + .5*f05 + .6*f06 + x/5 + c - (d4 + d5 + d6) + u
gen yinf = rpoisson(exp(yinfstar))
gen y4 = yinf
replace y4 = rpoisson(exp(yinfstar + .1 + (x - 1)/5 + .2*f05 + .3*f06 + rnormal(0,1))) if year >= 2004
gen y5 = yinf
replace y5 = rpoisson(exp(yinfstar + .3 + (x - 1)/5 + .2*f06 + rnormal(0,1))) if year >= 2005
gen y6 = yinf
replace y6 = rpoisson(exp(yinfstar + .2 + (x - 1)/5 + rnormal(0,1))) if year >= 2006
*/


gen yinfstar = 2 + .2*f02 + .3*f03 + .4*f04 + .5*f05 + .6*f06 + x/5 - (d4 + d5 + d6) + c
gen yinf = rpoisson(exp(yinfstar))
gen y4 = yinf
replace y4 = rpoisson(exp(yinfstar + .5 + (x - 1)/5 + .4*f05 + .6*f06)) if year >= 2004
gen y5 = yinf
replace y5 = rpoisson(exp(yinfstar + .8 + (x - 1)/5 + .4*f06)) if year >= 2005
gen y6 = yinf
replace y6 = rpoisson(exp(yinfstar + .3 + (x - 1)/5)) if year >= 2006


sum x if d4
gen x_dm4 = x - r(mean)
sum x if d5
gen x_dm5 = x - r(mean)
sum x if d6
gen x_dm6 = x - r(mean)

gen te_4i = y4 - yinf
sum te_4i if d4 & f04
sum te_4i if d4 & f05
sum te_4i if d4 & f06

gen te_5i = y5 - yinf
sum te_5i if d5 & f05
sum te_5i if d5 & f06

gen te_6i = y6 - yinf
sum te_6i if d6 & f06
	
* Observed outcome:

gen y = dinf*yinf + d4*y4 + d5*y5 + d6*y6

* Generate time-varying treatment indicator for staggered intervention:

gen w = d4*(f04 + f05 + f06) + d5*(f05 + f06) + d6*f06

* save did_staggered_6_count, replace

* Linear model:

reg y c.d4#c.f04 c.d4#c.f05 c.d4#c.f06 ///
	c.d5#c.f05 c.d5#c.f06 ///
	c.d6#c.f06 ///
	c.d4#c.f04#c.x_dm4 c.d4#c.f05#c.x_dm4 c.d4#c.f06#c.x_dm4 ///
	c.d5#c.f05#c.x_dm5 c.d5#c.f06#c.x_dm5 ///
	c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, vce(cluster id)
	
poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x i.w#c.d4#c.f05#c.x i.w#c.d4#c.f06#c.x ///
	i.w#c.d5#c.f05#c.x i.w#c.d5#c.f06#c.x ///
	i.w#c.d6#c.f06#c.x ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted vce(cluster id)
	

/*
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1 & f04 == 1) noestimcheck
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1 & f05 == 1) noestimcheck   
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1 & f06 == 1) noestimcheck   
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1 & f05 == 1) noestimcheck   
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1 & f06 == 1) noestimcheck   
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1 & f06 == 1) noestimcheck
*/
	
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1) noestimcheck
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1) noestimcheck
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1) noestimcheck
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1) noestimcheck

* Callaway and Sant'Anna:

gen first_treat = 0
replace first_treat = 2004 if d4
replace first_treat = 2005 if d5
replace first_treat = 2006 if d6

csdid y x, ivar(id) time(year) gvar(first_treat)
csdid y x, ivar(id) time(year) gvar(first_treat) method(reg)

capture program drop did_staggered

program did_staggered, rclass
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

gen c = rnormal(0,1)
bysort id: replace c = c[1]

* Add serial correlation in future.
gen u = rnormal(0,1)

* Generate treatment cohorts:

	gen trt = -.5 + x/2 + rnormal(0,1) > 0
	egen trt_sum = sum(trt), by(id)
	gen dinf = trt_sum <= 2
	gen d4 = trt_sum == 3
	gen d5 = trt_sum == 4
	gen d6 = trt_sum >= 5
	drop trt trt_sum
	
	sum dinf
	return scalar dinf_p = r(mean)
	sum d4
	return scalar d4_p = r(mean)
	sum d5
	return scalar d5_p = r(mean)
	sum d6
	return scalar d6_p = r(mean)

* Generate potential outcomes.

	gen yinfstar = 2 + .2*f02 + .3*f03 + .4*f04 + .5*f05 + .6*f06 + x/5 - (d4 + d5 + d6) + c
	gen yinf = rpoisson(exp(yinfstar))
	gen y4 = yinf
	replace y4 = rpoisson(exp(yinfstar + .5 + (x - 1)/5 + .4*f05 + .6*f06)) if year >= 2004
	gen y5 = yinf
	replace y5 = rpoisson(exp(yinfstar + .8 + (x - 1)/5 + .4*f06)) if year >= 2005
	gen y6 = yinf
	replace y6 = rpoisson(exp(yinfstar + .3 + (x - 1)/5)) if year >= 2006


/*
	gen yinfstar = 2 + .2*f02 + .3*f03 + .4*f04 + .5*f05 + .6*f06 + x/5 - (d4 + d5 + d6) + c
	gen yinf = exp(rnormal())*rpoisson(exp(yinfstar))
	gen y4 = yinf
	replace y4 = exp(rnormal())*rpoisson(exp(yinfstar + .5 + (x - 1)/5 + .4*f05 + .6*f06)) if year >= 2004
	gen y5 = yinf
	replace y5 = exp(rnormal())*rpoisson(exp(yinfstar + .8 + (x - 1)/5 + .4*f06)) if year >= 2005
	gen y6 = yinf
	replace y6 = exp(rnormal())*rpoisson(exp(yinfstar + .3 + (x - 1)/5)) if year >= 2006
*/

/*
	gen yinfstar = .2 + .2*f02 + .3*f03 + .4*f04 + .5*f05 + .6*f06 + x/5 + c - (d4 + d5 + d6) + u
	gen yinf = rpoisson(1)*exp(yinfstar)
	gen y4 = yinf
	replace y4 = rpoisson(1)*exp(yinfstar + .1 + (x - 1)/5 + .2*f05 + .3*f06 + rnormal(0,1)) if year >= 2004
	gen y5 = yinf
	replace y5 = rpoisson(1)*exp(yinfstar + .3 + (x - 1)/5+ .2*f06 + rnormal(0,1)) if year >= 2005
	gen y6 = yinf
	replace y6 = rpoisson(1)*exp(yinfstar + .2 + (x - 1)/5 + rnormal(0,1)) if year >= 2006
*/





	sum x if d4
	gen x_dm4 = x - r(mean)
	sum x if d5
	gen x_dm5 = x - r(mean)
	sum x if d6
	gen x_dm6 = x - r(mean)

	gen y = dinf*yinf + d4*y4 + d5*y5 + d6*y6

* Generate time-varying treatment indicator for staggered intervention:
	gen w = d4*(f04 + f05 + f06) + d5*(f05 + f06) + d6*f06

	xtset id year

	gen te_4i = y4 - yinf
	sum te_4i if d4 & f04
	return scalar att_44 = r(mean)
	sum te_4i if d4 & f05
	return scalar att_45 = r(mean)
	sum te_4i if d4 & f06
	return scalar att_46 = r(mean)

	gen te_5i = y5 - yinf
	sum te_5i if d5 & f05
	return scalar att_55 = r(mean)
	sum te_5i if d5 & f06
	return scalar att_56 = r(mean)

	gen te_6i = y6 - yinf
	sum te_6i if d6 & f06
	return scalar att_66 = r(mean)

* linear:

reg y c.d4#c.f04 c.d4#c.f05 c.d4#c.f06 ///
	c.d5#c.f05 c.d5#c.f06 ///
	c.d6#c.f06 ///
	c.d4#c.f04#c.x_dm4 c.d4#c.f05#c.x_dm4 c.d4#c.f06#c.x_dm4 ///
	c.d5#c.f05#c.x_dm5 c.d5#c.f06#c.x_dm5 ///
	c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x
	
	return scalar att_44_ra = _b[c.d4#c.f04]
	return scalar att_45_ra = _b[c.d4#c.f05]
	return scalar att_46_ra = _b[c.d4#c.f06]
	return scalar att_55_ra = _b[c.d5#c.f05]
	return scalar att_56_ra = _b[c.d5#c.f06]
	return scalar att_66_ra = _b[c.d6#c.f06]
	return scalar rsq = e(r2)
	
* Poisson

	poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x i.w#c.d4#c.f05#c.x i.w#c.d4#c.f06#c.x ///
	i.w#c.d5#c.f05#c.x i.w#c.d5#c.f06#c.x ///
	i.w#c.d6#c.f06#c.x ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x
	
	estimates store beta	

	margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1 & f04 == 1) noestimcheck post
	return scalar att_44_po = _b[1.w]
	
	estimates restore beta
	margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1 & f05 == 1) noestimcheck post
	return scalar att_45_po = _b[1.w]
	
	estimates restore beta
	margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1 & f06 == 1) noestimcheck post
	return scalar att_46_po = _b[1.w]
	
	estimates restore beta
	margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1 & f05 == 1) noestimcheck  post
	return scalar att_55_po = _b[1.w]
	
	estimates restore beta
	margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1 & f06 == 1) noestimcheck post
	return scalar att_56_po = _b[1.w]
	
	estimates restore beta
	margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1 & f06 == 1) noestimcheck post
	return scalar att_66_po = _b[1.w]
	
* Callaway and Sant'Anna:

	gen first_treat = 0
	replace first_treat = 2004 if d4
	replace first_treat = 2005 if d5
	replace first_treat = 2006 if d6
	csdid y x, ivar(id) time(year) gvar(first_treat) method(dripw) reps(1)
	return scalar att_44_cs = _b[g2004:t_2003_2004]
	return scalar att_45_cs = _b[g2004:t_2003_2005]
	return scalar att_46_cs = _b[g2004:t_2003_2006]
	return scalar att_55_cs = _b[g2005:t_2004_2005]
	return scalar att_56_cs = _b[g2005:t_2004_2006]
	return scalar att_66_cs = _b[g2006:t_2005_2006]
	
end

set seed 123

simulate r(att_44) r(att_45) r(att_46) ///
	r(att_55) r(att_56) r(att_66) ///
	r(att_44_ra) r(att_45_ra) r(att_46_ra) ///
	r(att_55_ra) r(att_56_ra) r(att_66_ra) ///
	r(att_44_po) r(att_45_po) r(att_46_po) ///
	r(att_55_po) r(att_56_po) r(att_66_po) ///
	r(att_44_cs) r(att_45_cs) r(att_46_cs) ///
	r(att_55_cs) r(att_56_cs) r(att_66_cs) ///
	r(rsq) r(dinf_p) r(d4_p) r(d5_p) r(d6_p), reps($iter): did_staggered
	
sum, sep(6)

/*

	r(att_44_cs) r(att_45_cs) r(att_46_cs) ///
	r(att_55_cs) r(att_56_cs) r(att_66_cs) ///
	
*/
	
log close

