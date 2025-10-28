/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script performs DD and DDD regressions excluding non-competitive
departments (NonCOMPET = 1) and units with large-scale personnel
migration. Regressions use reghdfe with department, treatment, and
university-by-time fixed effects, propensity score weights, and 
standard covariates.

Inputs:
- db_robcheck.dta: Cleaned panel data with constructed indicators.

Outputs:
- table_RC03_RedSample.[format]: DD and DDD regression results on
  reduced sample excluding problematic departments.
==================================================================*/


* --------------------------------------------------
* Data Import and Sample Restriction
* --------------------------------------------------

use "${data_path}/db_robcheck.dta", clear

* Drop non-competitive departments from the sample
keep if NonCOMPET != 1


* --------------------------------------------------
* Table 1: DD Estimation on Reduced Sample
* --------------------------------------------------

cap est drop all

foreach var of global y {

    * DD model with full specification and reduced sample
    qui reghdfe `var' ib0.treated##i.post2 $covar ///
        [pweight=w_ipw_pre], ///
        a(id treated i.uni_name_enc#i.post2) cluster(id)
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}


* --------------------------------------------------
* Table 1 - Panel A: DD Results on Reduced Sample
* --------------------------------------------------

esttab est3_* using "${output}/table_RC03_RedSample.${tab_fmt}", ///
    keep(1.treated#*)  ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.post2 "Treat X After" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear univyear contr pscore N_clust, labels( ///
        "Department and time FE" ///
        "University-by-time FE" ///
        "Time-varying controls" ///
        "Prop score weight" ///
        "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Effect of the Department of Excellence Programme on University Faculty Recruitment, restricted sample"}) ///
    replace


* --------------------------------------------------
* Table 2: DDD Estimation on Reduced Sample
* --------------------------------------------------

cap est drop _all

foreach var of global y {

    * DDD model on reduced sample with full specification
    qui reghdfe `var' ib0.treated##i.LOWdep##i.post2 $covar ///
        [pweight=w_ipw_pre], ///
        a(id treated i.uni_name_enc#i.post2) cluster(id)
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}


* --------------------------------------------------
* Table 2 - Panel A: DDD Results on Reduced Sample
* --------------------------------------------------

esttab est3_* using "${output}/table_RC03_RedSample.${tab_fmt}", ///
    keep(1.treated#1.L*#*post2)  ///
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
    stats(dptyear univyear contr pscore N_clust, labels( ///
        "Department and time FE" ///
        "University-by-time FE" ///
        "Time-varying controls" ///
        "Prop score weight" ///
        "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments, restricted sample"}) ///
    append
