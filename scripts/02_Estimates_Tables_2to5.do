/*=============================================================================*
* Project title: Beyond the Badge of Honour: The Effect of the Italian 
*	(Department of) Excellence Initiative on Staff Recruitment 
* Created by: Francesco Rentocchini and Ugo Rizzo
* Original Date: 21/03/2024
* Last Update: 11/3/2025
----------------------------------------------------------------------

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
- tables_01_DD_avg: DD regression results tables (Panel A & B).
- tables_02_DDD_avg: DDD regression results tables (Panel A & B).
==================================================================*/


// SET GLOBALS AND LOCALS FOR ANALYSIS
*=============================================================================*

global covar lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate

global y new_position new_entry new_endogamia new_rtda new_rtdb new_ten_uni_all	


global y1 est*_new_position est*_new_entry est*_new_endogamia
global y2 est*_new_rtda est*_new_rtdb est*_new_ten_uni_all

global plot_y1 est3_new_position est3_new_entry est3_new_endogamia	
global plot_y2 est3_new_rtda est3_new_rtdb est3_new_ten_uni_all

* p hat in notes to tables
local hat = uchar(770)              
local phat = "p`hat'"

// LOAD DATA
*=============================================================================*
use "${data_path}/db_robcheck.dta",clear



* --------------------------------------------------
* Difference-in-Differences (DD) Estimation: Overall
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
* Table 2 - DD on Faculty Recruitment
* -----------------------------------------------

esttab $y1 using "${output}/Table_02.${tab_fmt}", ///
    keep(1.treated#* lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    drop(1.treated#0.post2) ///
    varlabels( ///
        1.treated#1.post2 "Treat X After" ///
        lagi "# researchers" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and post FE" ///
               "Time-varying controls" ///
               "University-by-post FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the average treatment on the treated coefficient using 2014-2020 data. Regressions are based on 2,029 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Department, post treatement fixed effects are included in all specifications. Columns 2, 3, 5, 6, 8 and 9 also include university-by-post fixed effects. Regressions in columns 3, 6 and 9 are estimated using 1/(1-`phat'(x<sub>i</sub>)) to weight untreated observations and 1/`phat'(x<sub>i</sub>) otherwise. `phat'(x<sub>i</sub>) is the propensity score and is calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects. Standard errors clustered at the department level are in parentheses. ") ///
    nogaps onecell ///
	label ///
    title("Table 2: Effect of the Department of Excellence Programme on University Faculty Recruitment: new positions and internal promotions") ///
    replace

* --------------------------------------------------
* Table 3 - DD on Temporary & Tenure-Track
* --------------------------------------------------

esttab $y2 using "${output}/Table_03.${tab_fmt}", ///
    keep(1.treated#* lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    drop(1.treated#0.post2) ///
    varlabels( ///
        1.treated#1.post2 "Treat X After" ///
        lagi "# researchers" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and post FE" ///
               "Time-varying controls" ///
               "University-by-post FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the average treatment on the treated coefficients using 2014-2020 data. Regressions are based on 2,029 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Department, post treatment fixed effects are included in all specifications. Columns 2, 3, 5, 6, 8 and 9 also include university-by-post fixed effects. Regressions in columns 3, 6 and 9 are estimated using 1/(1-`phat'(x<sub>i</sub>)) to weight untreated observations and 1/`phat'(x<sub>i</sub>) otherwise. `phat'(x<sub>i</sub>) is the propensity score and is calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects. Standard errors clustered at the department level are in parentheses") ///
    nogaps onecell ///
	label ///
    title("Table 3 Effect of the Department of Excellence Programme on University Faculty Recruitment: temporary and permanent positions") ///
    replace


* --------------------------------------------------
* Difference-in-Difference-in-Differences (DDD): Second Tier University Departments
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



* --------------------------------------------------
* Table 4: Difference-in-Difference-in-Differences (DDD): Faculty Recruitment
* --------------------------------------------------
esttab $y1 using "${output}/Table_04.${tab_fmt}", ///
    keep(1.treated#1.L*#*post2 lagi dep_transfer_horizontal ///
         tot_premiale VA_percap unemp_rate) ///
    drop(1.treated#1.LOWdep#0.post2) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.LOWdep#1.post2 "Treat X Low X After" ///
        lagi "# researchers" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and post FE" ///
               "Time-varying controls" ///
               "University-by-post FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the average treatment on the treated coefficients for second tier departments using 2014-2020 data. Regressions are based on 2,029 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Department, post treatment fixed effects are included in all specifications. Columns 2, 3, 5, 6, 8 and 9 also include university-by-post fixed effects. Regressions in columns 3, 6 and 9 are estimated using 1/(1-`phat'(x<sub>i</sub>)) to weight untreated observations and 1/`phat'(x<sub>i</sub>) otherwise. `phat'(x<sub>i</sub>) is the propensity score and is calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects. Standard errors clustered at the department level are in parentheses. ") ///
    nogaps onecell ///
	label ///
    title("Table 4: Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments: new positions and internal promotions") ///
    replace

* -----------------------------------------------
* Table 5 - DDD Temporary & Tenure-Track
* -----------------------------------------------
esttab $y2 using "${output}/Table_05.${tab_fmt}", ///
    keep(1.treated#1.L*#*post2 lagi dep_transfer_horizontal ///
         tot_premiale VA_percap unemp_rate) ///
    drop(1.treated#1.LOWdep#0.post2) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.LOWdep#1.post2 "Treat X Low X After" ///
        lagi "# researchers" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore N_clust, ///
        labels("Department and post FE" ///
               "Time-varying controls" ///
               "University-by-post FE" ///
               "Prop score weight" ///
               "N (Departments)") fmt(0 0 0 0 0)) ///
    addnotes("Notes. This table displays the average treatment on the treated coefficients for second tier departments using 2014-2020 data. Regressions are based on 2,029 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Department, post treatment fixed effects are included in all specifications. Columns 2, 3, 5, 6, 8 and 9 also include university-by-post fixed effects. Regressions in columns 3, 6 and 9 are estimated using 1/(1-`phat'(x<sub>i</sub>)) to weight untreated observations and 1/`phat'(x<sub>i</sub>) otherwise. `phat'(x<sub>i</sub>) is the propensity score and is calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects. Standard errors clustered at the department level are in parentheses") ///
    nogaps onecell ///
	label ///
    title("Table 5: Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments: temporary and permanent positions") ///
    replace


* --------------------------------------------------
* Sanity Checks: Variable Means
* --------------------------------------------------

quietly summarize treated, meanonly
assert abs(r(mean) - 0.5103448) < 1e-6

quietly summarize LOWdep, meanonly
assert abs(r(mean) - 0.4862069) < 1e-6

quietly summarize post2, meanonly
assert abs(r(mean) - 0.4285714) < 1e-6
