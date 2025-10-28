/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script explores the impact of including covariates in DiD and 
DDD models. It compares simple linear models (OLS and reghdfe) with 
and without controls. It also applies the doubly robust DiD estimator 
from Sant'Anna & Zhao (2020), using both time-varying and pre-treatment 
covariates. Outputs are shown for average treatment effects across 
different employment outcomes.

Inputs:
- db_robcheck.dta: Panel dataset with treatment, outcomes, and covariates

Outputs:
- tables_RC09_covar_dr.[format]: DR-DiD results comparing covariate 
  inclusion strategies
==================================================================*/


* --------------------------------------------------
* Load Data
* --------------------------------------------------

use "${data_path}/db_robcheck.dta", clear


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* HOW ADDING COVARIATES POTENTIALLY MESSES UP ESTIMATES
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

* Treatment Effect (TE)
* ----------------------

** Without covariates
reg new_position ib0.treated##i.post2, cluster(id)
reghdfe new_position ib0.treated##i.post2, a(id) cluster(id)

** With covariates
reg new_position ib0.treated##i.post2 $covar, cluster(id)
reghdfe new_position ib0.treated##i.post2 $covar, a(id) cluster(id)


* Heterogeneous Treatment Effects
* -------------------------------

** Without covariates
reg new_position ib0.treated##i.LOWdep##i.post2, cluster(id)
reghdfe new_position ib0.treated##i.LOWdep##i.post2, ///
    a(id i.post2) cluster(id)

** With covariates
reg new_position ib0.treated##i.LOWdep##i.post2 $covar, cluster(id)
reghdfe new_position ib0.treated##i.LOWdep##i.post2 $covar, ///
    a(id i.post2) cluster(id)


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* 2x2 DID WITH COVARIATES – DOUBLY ROBUST (Sant'Anna & Zhao, 2020)
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

* Reference:
* Sant'Anna, P.H. and Zhao, J. (2020). Doubly robust difference-in-
* differences estimators. Journal of Econometrics, 219(1), pp.101–122.

* Collapse to 2x2 structure
collapse (mean) $y treated $covar LOWdep, by(id post2)
drop if post2 == .


* --------------------------------------------------
* DR-DID with Time-Varying Covariates
* --------------------------------------------------

preserve

drdid new_position $covar, ivar(id) time(post2) tr(treated) dripw
drdid_predict wgt, weight
tabstat $covar [w=wgt], by(treated)
drop wgt

foreach var of global y {
    di "`var'"
    drdid `var' $covar, ivar(id) time(post2) tr(treated) dripw
    est store est_`var'
}

esttab est_* using "${output}/tables_RC09_covar_dr.${tab_fmt}", ///
    mtitles("positions" "positions (excl. promotions)" "temporary" ///
    "tenure track" "tenured" "tenured internal" "tenured external" ///
    "internal promotions" "int promotions to full prof") ///
    varlabels(r1vs0.treated "Treat X After") ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) nogaps onecell replace

est drop _all
restore


* --------------------------------------------------
* DR-DID with Pre-Treatment Covariates
* --------------------------------------------------

preserve

foreach var of global covar {
    replace `var' = `var'[_n-1] if post2 == 1
}

drdid new_position $covar, ivar(id) time(post2) tr(treated) dripw
drdid_predict wgt, weight
tabstat $covar [w=wgt], by(treated)
drop wgt

foreach var of global y {
    di "`var'"
    drdid `var' $covar, ivar(id) time(post2) tr(treated) dripw
    est store est_`var'
}

esttab est_* using "${output}/tables_RC09_covar_dr.${tab_fmt}", ///
    mtitles("positions" "positions (excl. promotions)" "temporary" ///
    "tenure track" "tenured" "tenured internal" "tenured external" ///
    "internal promotions" "int promotions to full prof") ///
    varlabels(r1vs0.treated "Treat X After") ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) nogaps onecell append

restore
