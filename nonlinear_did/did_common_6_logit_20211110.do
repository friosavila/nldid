* Data generated to follow the logit model.

use did_common_6_binary, clear

log using did_common_6_binary, text replace

tab year
tab d if f06
tab y

* Because the data are generated, we can compute the sample ATTs. These 
* are unbiased for the population versions:

sum te_i if d & f04
sum te_i if d & f05
sum te_i if d & f06

* Linear model, first without adjusting standard errors for xbar:

reg y c.d#c.f04 c.d#c.f05 c.d#c.f06 ///
	c.d#c.f04#c.x_dm c.d#c.f05#c.x_dm c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x, vce(cluster id)
	
* Now adjust standard errors for xbar:

reg y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
* Logit:

logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
* Logit estimates much closer to sample ATTs. More precise, too.

/*
* Restricting the averaging to the "true" subsample, with the year is 
* specified too, is the same but output is more awkward. It's the same
* because the covariate does not change over time.

	
logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1 & f04 == 1) noestimcheck post
qui logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1 & f05 == 1) noestimcheck post
qui logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1 & f06 == 1) noestimcheck post
*/
	
* Callaway and Sant'Anna (2020, Journal of Econometrics):

gen first_treat = 0
replace first_treat = 2004 if d
csdid y x, ivar(id) time(year) gvar(first_treat)

* Like the linear model estimates, CS much smaller than the sample ATTs.
* Standard errors notably larger than logit.

log close

