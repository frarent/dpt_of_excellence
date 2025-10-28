/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script estimates the effects of the DoE programme using DD and
DDD models without additional controls, focusing on the impact of
bad controls by excluding time-varying covariates. It uses weighted
regressions (propensity score weights) and university-by-time fixed
effects.

Inputs:
- db_robcheck.dta: Dataset including constructed post indicator.

Outputs:
- table_RC01_badc.[format]: Table of DD and DDD results without covariates.
==================================================================*/


* --------------------------------------------------
* Data Import
* --------------------------------------------------

use "${data_path}/db_robcheck.dta", clear


* --------------------------------------------------
* Table 1: DD Estimation with Only Prop Score and FE
* --------------------------------------------------

cap est drop all

foreach var of global y {

    * DD model with propensity score weights and fixed effects only
    qui reghdfe `var' ib0.treated##i.post2 [pweight=w_ipw_pre], ///
        a(id i.uni_name_enc#i.post2) cluster(id)
    estadd local dptyear "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}


* --------------------------------------------------
* Table 1 - Panel A: DD Results
* --------------------------------------------------

esttab est3_* using "${output}/table_RC01_badc.${tab_fmt}", ///
    keep(1.treated#*) starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.post2 "Treat X After" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear univyear pscore N_clust, labels( ///
        "Department and time FE" ///
        "University-by-time FE" ///
        "Prop score weight" ///
        "N (Departments)") fmt(0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Effect of the Department of Excellence Programme on University Faculty Recruitment, exclusion of bad controls"}) ///
    replace


* --------------------------------------------------
* Table 2: DDD Estimation with Prop Score and FE
* --------------------------------------------------

cap est drop _all

foreach var of global y {

    * DDD model with propensity score weights and fixed effects only
    qui reghdfe `var' ib0.treated##i.LOWdep##i.post2 ///
        [pweight=w_ipw_pre], ///
        a(id i.post2 i.uni_name_enc#i.post2) cluster(id)
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}


* --------------------------------------------------
* Table 2 - Panel A: DDD Results
* --------------------------------------------------

esttab est3_* using "${output}/table_RC01_badc.${tab_fmt}", ///
    keep(1.treated#1.L*#*post2) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.LOWdep#1.post2 "Treat X Low X After" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear univyear pscore N_clust, labels( ///
        "Department and time FE" ///
        "University-by-time FE" ///
        "Prop score weight" ///
        "N (Departments)") fmt(0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments, exclusion of bad controls"}) ///
    append
