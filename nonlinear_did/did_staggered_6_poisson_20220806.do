* log using did_staggered_6_corner_20220806, text replace
* use did_staggered_6_corner, clear

use did_staggered_6_count, clear
log using did_staggered_6_count_20220806, text replace

xtset id year

sum dinf d4 d5 d6 if year == 2001
sum y
count if y == 0

* Exponential model for y, first without covariates, FE Poisson and 
* pooled Poisson given identical parameter estimates, but ATTs come
* from pooled Poisson. Without covariates, get same answer by excluding
* the pre-treatment year dummies.

poisson y c.d4#c.f04 c.d4#c.f05 c.d4#c.f06 ///
	c.d5#c.f05 c.d5#c.f06 ///
	c.d6#c.f06 ///
	f02 f03 f04 f05 f06 d4 d5 d6, vce(cluster id)
	
* Without covariates, the FE Poisson coefficient estimates are the same.
* But it's not clear how one would obtain ATTs (although suggestions
* are out there). Inference would be very difficult.
	
xtpoisson y c.d4#c.f04 c.d4#c.f05 c.d4#c.f06 ///
	c.d5#c.f05 c.d5#c.f06 ///
	c.d6#c.f06 ///
	i.year, fe vce(robust)
	
* Obtain ATTs using margins. Have to include w explicitly. Also, have to 
* set the cohort and year dummies accordingly:

qui poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	f02 f03 f04 f05 f06 d4 d5 d6, noomitted vce(cluster id)

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
	
* A different and very simple way to compute the ATTs and their standard errors.
* It also extends to the case of exit:

gen d4f04 = d4*f04
gen d4f05 = d4*f05
gen d4f06 = d4*f06
gen d5f05 = d5*f05	
gen d5f06 = d5*f06	
gen d6f06 = d6*f06

poisson y i.d4f04 i.d4f05 i.d4f06 i.d5f05 i.d5f06 i.d6f06 ///
	f02 f03 f04 f05 f06 d4 d5 d6, noomitted vce(cluster id)

margins, dydx(d4f04) subpop(if d4f04 == 1) noestimcheck vce(uncond)
margins, dydx(d4f05) subpop(if d4f05 == 1) noestimcheck vce(uncond)  
margins, dydx(d4f06) subpop(if d4f06 == 1) noestimcheck vce(uncond) 
margins, dydx(d5f05) subpop(if d5f05 == 1) noestimcheck vce(uncond)
margins, dydx(d5f06) subpop(if d5f06 == 1) noestimcheck vce(uncond) 
margins, dydx(d6f06) subpop(if d6f06 == 1) noestimcheck vce(uncond)

* Verify imputation estimates are the same [Wooldridge (2022, WP)]:
	
poisson y f02 f03 f04 f05 f06 d4 d5 d6 if ~w
predict double yh
gen teyh = y - yh
sum teyh if d4 & f04
sum teyh if d4 & f05
sum teyh if d4 & f06
sum teyh if d5 & f05
sum teyh if d5 & f06	
sum teyh if d6 & f06

* Now with a covariate. Use (time constant) covariates centered about cohort means 
* to get (roughly) proportionate effects as coefficients on the 6 treatment dummies:

poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x_dm4 i.w#c.d4#c.f05#c.x_dm4 i.w#c.d4#c.f06#c.x_dm4 ///
	i.w#c.d5#c.f05#c.x_dm5 i.w#c.d5#c.f06#c.x_dm5 ///
	i.w#c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted vce(cluster id)

margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)  
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1) noestimcheck vce(uncond)
	
* Verify averaging over the cohort subpopulations is sufficient:
	
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)  
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1) noestimcheck vce(uncond)
	
* The simpler method also extends to the case with covariates:

qui poisson y i.d4f04 i.d4f05 i.d4f06 i.d5f05 i.d5f06 i.d6f06 ///
	i.d4f04#c.x_dm4 i.d4f05#c.x_dm4 i.d4f06#c.x_dm4 ///
	i.d5f05#c.x_dm5 i.d5f06#c.x_dm5 ///
	i.d6f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted vce(cluster id)

margins, dydx(d4f04) subpop(if d4f04 == 1) noestimcheck vce(uncond)
margins, dydx(d4f05) subpop(if d4f05 == 1) noestimcheck vce(uncond)  
margins, dydx(d4f06) subpop(if d4f06 == 1) noestimcheck vce(uncond) 
margins, dydx(d5f05) subpop(if d5f05 == 1) noestimcheck vce(uncond)
margins, dydx(d5f06) subpop(if d5f06 == 1) noestimcheck vce(uncond) 
margins, dydx(d6f06) subpop(if d6f06 == 1) noestimcheck vce(uncond)

* Imputation estimates are still the same with time-constant covariates. 
* Again, no easy way to obtain analytical standard errors:
	
drop yh teyh
	
poisson y f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x if ~w
	
predict double yinfh
gen teyh = y - yinfh
sum teyh if d4 & f04
sum teyh if d4 & f05
sum teyh if d4 & f06
sum teyh if d5 & f05
sum teyh if d5 & f06	
sum teyh if d6 & f06

* With heterogeneous trends:

poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x_dm4 i.w#c.d4#c.f05#c.x_dm4 i.w#c.d4#c.f06#c.x_dm4 ///
	i.w#c.d5#c.f05#c.x_dm5 i.w#c.d5#c.f06#c.x_dm5 ///
	i.w#c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x ///
	c.d4#c.year c.d5#c.year c.d6#c.year, noomitted vce(cluster id)
test c.d4#c.year c.d5#c.year c.d6#c.year

margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0 year = 2004) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0 year = 2005) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)  
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 year = 2006) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0 year = 2005) ///
	subpop(if d5 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 year = 2006) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 year = 2006) ///
	subpop(if d6 == 1) noestimcheck vce(uncond)

/*

* Same answer if you start the trend at one.

gen t = year - 2000
	
poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x_dm4 i.w#c.d4#c.f05#c.x_dm4 i.w#c.d4#c.f06#c.x_dm4 ///
	i.w#c.d5#c.f05#c.x_dm5 i.w#c.d5#c.f06#c.x_dm5 ///
	i.w#c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x ///
	c.d4#c.t c.d5#c.t c.d6#c.t, noomitted vce(cluster id)
test c.d4#c.t c.d5#c.t c.d6#c.t

margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0 t = 4) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0 t = 5) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)  
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 t = 6) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0 t = 5) ///
	subpop(if d5 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 t = 6) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1 t = 6) ///
	subpop(if d6 == 1) noestimcheck vce(uncond)
	
*/

* Imputation with heterogeneous trends:

drop yinfh teyh

poisson y f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x ///
	c.d4#c.year c.d5#c.year c.d6#c.year if ~w, noomitted vce(cluster id)
test c.d4#c.year c.d5#c.year c.d6#c.year 
predict double yinfh
gen teyh = y - yinfh if w == 1
sum teyh if d4 & f04
sum teyh if d4 & f05
sum teyh if d4 & f06
sum teyh if d5 & f05
sum teyh if d5 & f06	
sum teyh if d6 & f06

* Linear Model:

reg y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x_dm4 i.w#c.d4#c.f05#c.x_dm4 i.w#c.d4#c.f06#c.x_dm4 ///
	i.w#c.d5#c.f05#c.x_dm5 i.w#c.d5#c.f06#c.x_dm5 ///
	i.w#c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted vce(cluster id)
	
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)  
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) 
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1) noestimcheck vce(uncond)
	
/*

* Simpler method of obtaining ATTs:

qui reg y i.d4f04 i.d4f05 i.d4f06 i.d5f05 i.d5f06 i.d6f06 ///
	i.d4f04#c.x_dm4 i.d4f05#c.x_dm4 i.d4f06#c.x_dm4 ///
	i.d5f05#c.x_dm5 i.d5f06#c.x_dm5 ///
	i.d6f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted vce(cluster id)

margins, dydx(d4f04) subpop(if d4f04 == 1) noestimcheck vce(uncond)
margins, dydx(d4f05) subpop(if d4f05 == 1) noestimcheck vce(uncond)  
margins, dydx(d4f06) subpop(if d4f06 == 1) noestimcheck vce(uncond) 
margins, dydx(d5f05) subpop(if d5f05 == 1) noestimcheck vce(uncond)
margins, dydx(d5f06) subpop(if d5f06 == 1) noestimcheck vce(uncond) 
margins, dydx(d6f06) subpop(if d6f06 == 1) noestimcheck vce(uncond)
	
*/
	
* Test for non-parallel trends in linear model. It rejects with p < 0.05,
* indicating a problem with the linear model:

reg y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x_dm4 i.w#c.d4#c.f05#c.x_dm4 i.w#c.d4#c.f06#c.x_dm4 ///
	i.w#c.d5#c.f05#c.x_dm5 i.w#c.d5#c.f06#c.x_dm5 ///
	i.w#c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x ///
	c.d4#c.year c.d5#c.year c.d6#c.year, noomitted vce(cluster id)
test c.d4#c.year c.d5#c.year c.d6#c.year

	
* Callaway and Sant'Anna (2021, Journal of Econometrics).
* Uses long differences and ignores the nonnegative, corner solution nature of y.

gen first_treat = 0
replace first_treat = 2004 if d4
replace first_treat = 2005 if d5
replace first_treat = 2006 if d6
csdid y x, ivar(id) time(year) gvar(first_treat)

* Go back to model assuming PT holds. Would like to aggregate the ATTs
* into, say, one effect.
* Ideally, one could apply "lincom" after the ATTs have been obtained.
* This would allow obtaining standard errors after aggregating effects.

poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x i.w#c.d4#c.f05#c.x i.w#c.d4#c.f06#c.x ///
	i.w#c.d5#c.f05#c.x i.w#c.d5#c.f06#c.x ///
	i.w#c.d6#c.f06#c.x ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted vce(cluster id)
estimates store beta
	
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) post
scalar tau44 = _b[1.w]
di tau44
estimates restore beta
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck vce(uncond)  post
scalar tau45 = _b[1.w]
di tau45
estimates restore beta
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1) noestimcheck vce(uncond) post
scalar tau46 = _b[1.w]
di tau46
estimates restore beta
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) post
scalar tau55 = _b[1.w]
di tau55
estimates restore beta
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1) noestimcheck vce(uncond) post
scalar tau56 = _b[1.w]
di tau56
estimates restore beta
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1) noestimcheck vce(uncond) post
scalar tau66 = _b[1.w]
di tau66
scalar tauavg = (tau44 + tau45 + tau46 + tau55 + tau56 + tau66)/6
di tauavg

* Instead, bootstrap. Also shows the analytic standard errors work well
* even though the model is nonlinear, there is clustering, and the 
* cohorts are not especially large.

xtset, clear

capture program drop aggregate_boot
	
program aggregate_boot, rclass

poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x_dm4 i.w#c.d4#c.f05#c.x_dm4 i.w#c.d4#c.f06#c.x_dm4 ///
	i.w#c.d5#c.f05#c.x_dm5 i.w#c.d5#c.f06#c.x_dm5 ///
	i.w#c.d6#c.f06#c.x_dm6 ///
	f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x ///
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x, noomitted
estimates store beta
	
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck post nose
scalar t44 = _b[1.w]
return scalar tau44 = _b[1.w]
estimates restore beta
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1) noestimcheck post nose
scalar t45 = _b[1.w]
return scalar tau45 = _b[1.w]
estimates restore beta
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1) noestimcheck post nose
scalar t46 = _b[1.w]
return scalar tau46 = _b[1.w]
estimates restore beta
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1) noestimcheck post nose
scalar t55 = _b[1.w]
return scalar tau55 = _b[1.w]
estimates restore beta
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1) noestimcheck post nose
scalar t56 = _b[1.w]
return scalar tau56 = _b[1.w]
estimates restore beta
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1) noestimcheck post nose
scalar t66 = _b[1.w]
return scalar tau66 = _b[1.w]

return scalar tauavg = (t44 + t45 + t46 + t55 + t56 + t66)/6

end

bootstrap r(tau44) r(tau45) r(tau46) r(tau55) r(tau56) r(tau66) r(tauavg),  ///
	reps(500) seed(123) cluster(id) idcluster(newid): aggregate_boot


log close
	



