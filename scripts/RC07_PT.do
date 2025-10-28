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


* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* CONDITIONAL PARALLEL TRENDS TEST (WITH COVARIATES)
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_robcheck.dta", clear
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

* Export DD conditional PT table
esttab $y1 $y2 using "${output}/tables_RC07_PT.${tab_fmt}", ///
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
    stats(dptyear contr univyear pscore ftest N N_clust, labels( ///
        "Department and year FE" ///
        "Time-varying controls" ///
        "University-by-year FE" ///
        "Prop score weight" ///
        "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Pre-treatment trends: parallel trend assumption"}) ///
    replace

/*
* Conditional PT test: DDD model
cap est drop _all

foreach var of global y {

    qui reghdfe `var' ib0.treated##i.LOWdep##b2017.year $covar ///
        [pweight=w_ipw_pre], ///
        a(id treated i.uni_name_enc#i.year) cluster(id)
    test 1.treated#1.LOWdep#2014.year ///
         1.treated#1.LOWdep#2015.year ///
         1.treated#1.LOWdep#2016.year
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}

esttab $y1 $y2 using "${output}/tables_RC07_PT.${tab_fmt}", ///
    keep(1.treated#1.L*#*year) starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.LOWdep#2014.year "Treat X Low X Year 2014" ///
        1.treated#1.LOWdep#2015.year "Treat X Low X Year 2015" ///
        1.treated#1.LOWdep#2016.year "Treat X Low X Year 2016" ///
        1.treated#1.LOWdep#2017.year "Treat X Low X Year 2017 (omitted)" ///
        1.treated#1.LOWdep#2018.year "Treat X Low X Year 2018" ///
        1.treated#1.LOWdep#2019.year "Treat X Low X Year 2019" ///
        1.treated#1.LOWdep#2020.year "Treat X Low X Year 2020" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore ftest N N_clust, labels( ///
        "Department and year FE" ///
        "Time-varying controls" ///
        "University-by-year FE" ///
        "Prop score weight" ///
        "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Table XXX} {DDD - Effect of DoE programme on faculty recruitment, parallel trend}) ///
    append
*/

* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* UNCONDITIONAL PARALLEL TRENDS TEST (NO COVARIATES)
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_robcheck.dta", clear
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

esttab est3_* using "${output}/tables_RC08_UPT.${tab_fmt}", ///
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
    stats(dptyear contr univyear pscore ftest N N_clust, labels( ///
        "Department and year FE" ///
        "Time-varying controls" ///
        "University-by-year FE" ///
        "Prop score weight" "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Pre-treatment trends with no controls: unconditional parallel trend"}) ///
    replace

/*
* Unconditional PT test: DDD model
cap est drop _all

foreach var of global y {

    qui reghdfe `var' ib0.treated##i.LOWdep##b2017.year ///
        [pweight=w_ipw_pre], ///
        a(id treated) cluster(id)
    test 1.treated#1.LOWdep#2014.year ///
         1.treated#1.LOWdep#2015.year ///
         1.treated#1.LOWdep#2016.year
    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "No"
    estadd local univyear "No"
    estadd local pscore "Yes"
    est store est3_`var'

}

esttab est3_* using "${output}/tables_RC08_UPT.${tab_fmt}", ///
    keep(1.treated#1.L*#*year) starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.LOWdep#2014.year "Treat X Low X Year 2014" ///
        1.treated#1.LOWdep#2015.year "Treat X Low X Year 2015" ///
        1.treated#1.LOWdep#2016.year "Treat X Low X Year 2016" ///
        1.treated#1.LOWdep#2017.year "Treat X Low X Year 2017 (omitted)" ///
        1.treated#1.LOWdep#2018.year "Treat X Low X Year 2018" ///
        1.treated#1.LOWdep#2019.year "Treat X Low X Year 2019" ///
        1.treated#1.LOWdep#2020.year "Treat X Low X Year 2020" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore ftest N N_clust, labels( ///
        "Department and year FE" "Time-varying controls" ///
        "University-by-year FE" "Prop score weight" "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Table XXX} {DDD - Effect of DoE programme on faculty recruitment, parallel trend}) ///
    append
*/