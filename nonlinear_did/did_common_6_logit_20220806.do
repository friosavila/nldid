* Data generated to follow the logit model.

use did_common_6_binary, clear

xtset id year

log using did_common_6_binary_20220806, text replace

tab year
tab d if f06
tab y

* Because the data are generated, we can compute the sample ATTs. These 
* are unbiased for the population ATTs:

sum te_i if d & f04
sum te_i if d & f05
sum te_i if d & f06

* Linear model, first without adjusting standard errors for xbar:

reg y c.d#c.f04 c.d#c.f05 c.d#c.f06 ///
	c.d#c.f04#c.x_dm c.d#c.f05#c.x_dm c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x, noomitted vce(cluster id)
		
* Now adjust standard errors for xbar using the vce(uncon) option. Stata
* output looks better by including c.d in the treatment indicator:

reg y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.d#c.f04#c.x_dm i.w#c.d#c.d#c.f05#c.x_dm i.w#c.d#c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
* Logit. Again, Stata output looks better by including c.d in the treatment 
* indicator even though it is redundant:

logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.f06 ///
	i.w#c.d#c.f04#c.x_dm i.w#c.d#c.f05#c.x_dm i.w#c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)

* Without c.d in the treatment indicator:
	
logit y i.w#c.f04 i.w#c.f05 i.w#c.f06 ///
	i.w#c.f04#c.x_dm i.w#c.f05#c.x_dm i.w#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
qui logit y i.w#c.f04 i.w#c.f05 i.w#c.f06 ///
	i.w#c.f04#c.x_dm i.w#c.f05#c.x_dm i.w#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
qui logit y i.w#c.f04 i.w#c.f05 i.w#c.f06 ///
	i.w#c.f04#c.x_dm i.w#c.f05#c.x_dm i.w#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	noestimcheck vce(uncond)
	
* Logit estimates much closer to sample ATTs. More precise, too.

* Imputation gives same estimates:

logit y f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x if ~w, noomitted vce(cluster id)

predict double y0h
gen teyh = y - y0h
sum teyh if d & f04
sum teyh if d & f05
sum teyh if d & f06


* Callaway and Sant'Anna (2021, Journal of Econometrics):

gen first_treat = 0
replace first_treat = 2004 if d
csdid y x, ivar(id) time(year) gvar(first_treat)

* Like the linear model estimates, CS much smaller than the sample ATTs.
* Standard errors notably larger than logit.

* Test/adjust for failure of parallel trends.
* Estimated effects are much less precise:

* First the "event study" test:
logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x c.d#c.f02 c.d#c.f03, noomitted vce(cluster id)
test c.d#c.f02 c.d#c.f03

* Confirm get same as using only control observations:
logit y f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x c.d#c.f02 c.d#c.f03 if ~w, noomitted vce(cluster id)
test c.d#c.f02 c.d#c.f03


* Heterogeneous trend test and compute ATTs with trend:

gen t = year - 2000

logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x i.w#c.d#c.f05#c.x i.w#c.d#c.f06#c.x ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x c.d#c.t, noomitted vce(cluster id)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0 t = 4) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0 t = 5) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 t = 6) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
drop y0h teyh

* Imputation with heterogeneous trend:
	
logit y f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x c.d#c.t if ~w, noomitted vce(cluster id)
predict double y0h
gen teyh = y - y0h
sum teyh if d & f04
sum teyh if d & f05
sum teyh if d & f06
	
reg y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x_dm i.w#c.d#c.f05#c.x_dm i.w#c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x c.d#c.f02 c.d#c.f03, noomitted vce(cluster id)
test c.d#c.f02 c.d#c.f03

* Linear with heterogeneous trend:
	
reg y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x_dm i.w#c.d#c.f05#c.x_dm i.w#c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d x c.d#c.x c.d#c.t, noomitted vce(cluster id)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d == 1) noestimcheck vce(uncond)
	
* Test for violation of NA by including lead indicator:
logit y i.w#c.d#c.f04 i.w#c.d#c.f05 i.w#c.d#c.f06 ///
	i.w#c.d#c.f04#c.x_dm i.w#c.d#c.f05#c.x_dm i.w#c.d#c.f06#c.x_dm ///
	f02 f03 f04 f05 f06 c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d x c.d#c.x F.w, noomitted vce(cluster id)

log close

