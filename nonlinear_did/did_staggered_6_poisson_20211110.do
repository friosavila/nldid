log using did_staggered_6_corner, text replace
use did_staggered_6_corner, clear


* use did_staggered_6_count, clear
* log using did_staggered_6_count, text replace

xtset id year
sort id year

sum dinf d4 d5 d6 if year == 2001
sum y
count if y == 0

* Compute sample ATTs:

gen te_4i = y4 - yinf
sum te_4i if d4 & f04
sum te_4i if d4 & f05
sum te_4i if d4 & f06

gen te_5i = y5 - yinf
sum te_5i if d5 & f05
sum te_5i if d5 & f06

gen te_6i = y6 - yinf
sum te_6i if d6 & f06

* Exponential model for y, first without covariates, FE Poisson and 
* pooled Poisson given identical parameter estimates, but ATTs come
* from pooled Poisson. Without covariates, get same answer by excluding
* the pre-treatment year dummies.

poisson y c.d4#c.f04 c.d4#c.f05 c.d4#c.f06 ///
	c.d5#c.f05 c.d5#c.f06 ///
	c.d6#c.f06 ///
	f04 f05 f06 d4 d5 d6, vce(cluster id)
	
poisson y c.d4#c.f04 c.d4#c.f05 c.d4#c.f06 ///
	c.d5#c.f05 c.d5#c.f06 ///
	c.d6#c.f06 ///
	f02 f03 f04 f05 f06 d4 d5 d6, vce(cluster id)
	
* Obtain ATTs using margins. Have to include w explicitly:

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


* Imputation estimators are the same:
	
poisson y f02 f03 f04 f05 f06 d4 d5 d6 if ~w
predict double yh
gen teyh = y - yh
sum teyh if d4 & f04
sum teyh if d4 & f05
sum teyh if d4 & f06
sum teyh if d5 & f05
sum teyh if d5 & f06	
sum teyh if d6 & f06

* Now with a covariate:

poisson y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x i.w#c.d4#c.f05#c.x i.w#c.d4#c.f06#c.x ///
	i.w#c.d5#c.f05#c.x i.w#c.d5#c.f06#c.x ///
	i.w#c.d6#c.f06#c.x ///
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
	
* For some reason, averaging over the "correct" cells makes the output look
* worse. But the estimates and standard errors are the same.
	
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 1 f05 = 0 f06 = 0) ///
	subpop(if d4 == 1 & f04 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d4 == 1 & f05 == 1) noestimcheck vce(uncond)  
margins, dydx(w) at(d4 = 1 d5 = 0 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d4 == 1 & f06 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 1 f06 = 0) ///
	subpop(if d5 == 1 & f05 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 1 d6 = 0 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d5 == 1 & f06 == 1) noestimcheck vce(uncond)
margins, dydx(w) at(d4 = 0 d5 = 0 d6 = 1 f02 = 0 f03 = 0 f04 = 0 f05 = 0 f06 = 1) ///
	subpop(if d6 == 1 & f06 == 1) noestimcheck vce(uncond)
	
* Imputation estimates are still the same:
	
drop yh teyh
	
poisson y f02 f03 f04 f05 f06 ///
	c.f02#c.x c.f03#c.x c.f04#c.x c.f05#c.x c.f06#c.x /// 
	d4 d5 d6 x c.d4#c.x c.d5#c.x c.d6#c.x if ~w
	
predict double yh
gen teyh = y - yh
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
	
* Adjust standard errors for sample averages of x over cohorts:

qui reg y i.w#c.d4#c.f04 i.w#c.d4#c.f05 i.w#c.d4#c.f06 ///
	i.w#c.d5#c.f05 i.w#c.d5#c.f06 ///
	i.w#c.d6#c.f06 ///
	i.w#c.d4#c.f04#c.x i.w#c.d4#c.f05#c.x i.w#c.d4#c.f06#c.x ///
	i.w#c.d5#c.f05#c.x i.w#c.d5#c.f06#c.x ///
	i.w#c.d6#c.f06#c.x ///
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
	
* Callaway and Sant'Anna (2020, Journal of Econometrics)
gen first_treat = 0
replace first_treat = 2004 if d4
replace first_treat = 2005 if d5
replace first_treat = 2006 if d6
csdid y x, ivar(id) time(year) gvar(first_treat)
	
log close

