/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script implements parallel trends checks using both DD and DDD 
event study specifications. The first block evaluates conditional PT 
(on covariates), while the second runs the test without conditioning.
These are robustness checks to support identifying assumptions.

Inputs:
- db_robcheck.dta: Department-year panel data, pre-treatment only

Outputs:
- tables_RC07_PT.[format]: DD and DDD tables (conditional PT)
- tables_RC08_UPT.[format]: DD and DDD tables (unconditional PT)
==================================================================*/


* --------------------------------------------------
* Project: Beyond the Badge of Honour: The Effect of
* the Italian (Department of) Excellence Initiative
* on Staff Recruitment
* Author: Francesco Rentocchini and Ugo Rizzo
* Date: 12 Nov 2025
*
* Code Description
* - Purpose: Check parallel-trend assumptions with DD models:
*   (i) conditional on covariates and FEs; (ii) unconditional.
* - Data inputs: ${data_path}/data_for_analysis.dta
* - Expected outputs:
*   - ${output}/Table_07.${tab_fmt} (conditional PT test)
*   - ${output}/Table_08.${tab_fmt} (unconditional PT test)
* --------------------------------------------------

* --------------------------------------------------
* Globals & locals (SET GLOBALS AND LOCALS FOR ANALYSIS)
* --------------------------------------------------

global covar lagi dep_transfer_horizontal tot_premiale VA_percap ///
    unemp_rate

global y new_position new_entry new_endogamia new_rtda ///
    new_rtdb new_ten_uni_all

global y1 est*_new_position est*_new_entry est*_new_endogamia
global y2 est*_new_rtda est*_new_rtdb est*_new_ten_uni_all

global plot_y1 est3_new_position est3_new_entry est3_new_endogamia
global plot_y2 est3_new_rtda est3_new_rtdb est3_new_ten_uni_all

* p hat in notes to tables
local hat = uchar(770)
local phat = "p`hat'"

* --------------------------------------------------
* Conditional parallel trends (WITH COVARIATES)
* --------------------------------------------------

use "${data_path}/data_for_analysis.dta", clear
keep if year <= 2017

cap est drop _all

foreach var of global y {

    * Conditional PT test: DD model
    qui reghdfe `var' ib0.treated##b2017.year $covar ///
        [pweight=w_ipw_pre], ///
        a(id i.uni_name_enc#i.year) cluster(id)
    test 1.treated#2014.year 1.treated#2015.year 1.treated#2016.year
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}

* --------------------------------------------------
* Export: Table 7 (DD conditional PT)
* --------------------------------------------------

esttab $y1 $y2 using "${output}/Table_07.${tab_fmt}", ///
    keep(1.treated#*) starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#2014.year "Treat X Year 2014" ///
        1.treated#2015.year "Treat X Year 2015" ///
        1.treated#2016.year "Treat X Year 2016" ///
        1.treated#2017.year "Treat X Year 2017 (omitted)" ///
        1.treated#2018.year "Treat X Year 2018" ///
        1.treated#2019.year "Treat X Year 2019" ///
        1.treated#2020.year "Treat X Year 2020" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
        unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore ftest N N_clust, ///
        labels( ///
        "Department and post FE" ///
        "Time-varying controls" ///
        "University-by-post FE" ///
        "Prop score weight" ///
        "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") ///
        fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the pre-treatment event study coefficients using 2014-2016 data. Regressions are based on 1,104 department-year observations. Estimates include controls for the number of employees at t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Department, year and university-by-year fixed effects are included in all specifications. All regressions are estimated using 1/(1-`phat'(x<sub>i</sub>)) to weight untreated observations and 1/`phat'(x<sub>i</sub>) otherwise. `phat'(x<sub>i</sub>)  is the propensity score and is calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
    mtitles("New positions" "New positions (excl. promotions)" ///
    "Internal promotions" "Temporary" "Tenure track" "Tenured") ///
    label ///
    title("Table 7: Pre-treatment trends: parallel trend assumption") ///
    replace

* --------------------------------------------------
* Unconditional parallel trends test (NO COVARIATES)
* --------------------------------------------------

use "${data_path}/data_for_analysis.dta", clear
keep if year >= 2014 & year <= 2017

cap est drop _all

foreach var of global y {

    * Unconditional PT test: DD model
    qui reghdfe `var' ib0.treated##b2017.year ///
        [pweight=w_ipw_pre], ///
        a(id) cluster(id)
    test 1.treated#2014.year 1.treated#2015.year 1.treated#2016.year
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "No"
    estadd local univyear "No"
    estadd local pscore "Yes"
    est store est3_`var'

}

* --------------------------------------------------
* Export: Table 8 (DD unconditional PT)
* --------------------------------------------------

esttab est3_* using "${output}/Table_08.${tab_fmt}", ///
    keep(1.treated#*) starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#2014.year "Treat X Year 2014" ///
        1.treated#2015.year "Treat X Year 2015" ///
        1.treated#2016.year "Treat X Year 2016" ///
        1.treated#2017.year "Treat X Year 2017 (omitted)" ///
        1.treated#2018.year "Treat X Year 2018" ///
        1.treated#2019.year "Treat X Year 2019" ///
        1.treated#2020.year "Treat X Year 2020" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
        unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore ftest N N_clust, ///
        labels( ///
        "Department and post FE" ///
        "Time-varying controls" ///
        "University-by-post FE" ///
        "Prop score weight" "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") ///
        fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the pre-treatment event study coefficients using 2014-2016 data. Regressions are based on 1,160 department-year observations. Department and year fixed effects are included in all specifications. All regressions are estimated using 1/(1-`phat'(x<sub>i</sub>)) to weight untreated observations and 1/`phat'(x<sub>i</sub>) otherwise. `phat'(x<sub>i</sub>) is the propensity score and is calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects. Standard errors clustered at the department level are in parentheses. ") ///
    nogaps onecell noomitted ///
    mtitles("New positions" "New positions (excl. promotions)" ///
    "Internal promotions" "Temporary" "Tenure track" "Tenured") ///
    label ///
    title("Table 8: Pre-treatment trends with no controls: unconditional parallel trend") ///
    replace
