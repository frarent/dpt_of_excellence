/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script prepares and analyzes panel data to evaluate the effect of
the Department of Excellence (DoE) programme on faculty hiring. It
includes construction of pre/post indicators, and difference-in-
differences (DD) and difference-in-differences-in-differences (DDD)
regression estimations using department-level panel data from 2014–2020.

Inputs:
- db_before_est.dta: Main panel dataset with department-year observations.

Outputs:
- db_robcheck.dta: Dataset with pre/post treatment indicator saved.
- tables_01_DD_avg.[format]: DD regression results tables (Panel A & B).
- tables_02_DDD_avg.[format]: DDD regression results tables (Panel A & B).
==================================================================*/


* --------------------------------------------------
* Data Import and Construction of Post Indicator
* --------------------------------------------------

use "${data_path}/db_before_est.dta", clear

cap est drop _all

* Create post-treatment indicator for 2018–2020
gen post2 = 1 if year >= 2018 & year <= 2020
replace post2 = 0 if year >= 2014 & year <= 2017

// this definition yields same results
* gen post3 = 1 if year >= 2018 & year <= 2020
* replace post3 = 0 if year >= 2013 & year <= 2017

compress
save "${data_path}/db_robcheck.dta", replace


* --------------------------------------------------
* Table 1: Difference-in-Differences (DD) Estimation
* --------------------------------------------------

cap est drop _all

foreach var of global y {

    * Department and year fixed effects
    qui reghdfe `var' ib0.treated##i.post2 $covar, ///
        a(id) cluster(id)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "No"
    estadd local pscore "No"
    est store est1_`var'

    * Add university-by-year fixed effects
    qui reghdfe `var' ib0.treated##i.post2 $covar, ///
        a(id i.uni_name_enc#i.post2) cluster(id)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "No"
    est store est2_`var'

    * Add propensity score weights
    qui reghdfe `var' ib0.treated##i.post2 $covar ///
        [pweight=w_ipw_pre], ///
        a(id i.uni_name_enc#i.post2) cluster(id)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'
}

* -----------------------------------------------
* Table 1 - Panel A: DD on Faculty Recruitment
* -----------------------------------------------

esttab $y1 using "${output}/tables_01_DD_avg.${tab_fmt}", ///
    keep(1.treated#* lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    drop(1.treated#0.post2) ///
    varlabels( ///
        1.treated#1.post2 "Treat X After" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and year FE" ///
               "Time-varying controls" ///
               "University-by-year FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Table 1} {"Effect of the Department of Excellence Programme on University Faculty Recruitment: new positions and internal promotions"}) ///
    replace

* --------------------------------------------------
* Table 1 - Panel B: DD on Temporary & Tenure-Track
* --------------------------------------------------

esttab $y2 using "${output}/tables_01_DD_avg.${tab_fmt}", ///
    keep(1.treated#* lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    drop(1.treated#0.post2) ///
    varlabels( ///
        1.treated#1.post2 "Treat X After" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and year FE" ///
               "Time-varying controls" ///
               "University-by-year FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Table 2} {"Effect of the Department of Excellence Programme on University Faculty Recruitment: temporary and permanent positions"}) ///
    append


* --------------------------------------------------
* Table 2: Difference-in-Difference-in-Differences (DDD)
* --------------------------------------------------

cap est drop _all

foreach var of global y {

    * Base DDD model
    qui reghdfe `var' ib0.treated##i.LOWdep##i.post2 $covar, ///
        a(id i.post2) cluster(id)
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "No"
    estadd local pscore "No"
    est store est1_`var'

    * Add university-by-year FE
    qui reghdfe `var' ib0.treated##i.LOWdep##i.post2 $covar, ///
        a(id i.post2 i.uni_name_enc#i.post2) cluster(id)
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "No"
    est store est2_`var'

    * Add propensity score weights
    qui reghdfe `var' ib0.treated##i.LOWdep##i.post2 $covar ///
        [pweight=w_ipw_pre], ///
        a(id i.post2 i.uni_name_enc#i.post2) cluster(id)
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'
}


* -----------------------------------------------
* Table 2 - Panel A: DDD Results - Faculty Hiring
* -----------------------------------------------

esttab $y1 using "${output}/tables_02_DDD_avg.${tab_fmt}", ///
    keep(1.treated#1.L*#*post2 lagi dep_transfer_horizontal ///
         tot_premiale VA_percap unemp_rate) ///
    drop(1.treated#1.LOWdep#0.post2) ///
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
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and year FE" ///
               "Time-varying controls" ///
               "University-by-year FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Panel A} {"Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments: new positions and internal promotions"}) ///
    replace

* Panel B: Append Additional Results
esttab $y2 using "${output}/tables_02_DDD_avg.${tab_fmt}", ///
    keep(1.treated#1.L*#*post2 lagi dep_transfer_horizontal ///
         tot_premiale VA_percap unemp_rate) ///
    drop(1.treated#1.LOWdep#0.post2) ///
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
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and year FE" ///
               "Time-varying controls" ///
               "University-by-year FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Panel A} {"Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments: temporary and permanent positions"}) ///
    append


* --------------------------------------------------
* Sanity Checks: Variable Means
* --------------------------------------------------

quietly summarize treated, meanonly
assert abs(r(mean) - 0.5103448) < 1e-6

quietly summarize LOWdep, meanonly
assert abs(r(mean) - 0.4862069) < 1e-6

quietly summarize post2, meanonly
assert abs(r(mean) - 0.4285714) < 1e-6
