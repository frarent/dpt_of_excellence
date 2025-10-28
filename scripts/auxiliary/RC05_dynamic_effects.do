/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script estimates dynamic treatment effects (event study approach)
via DD and DDD models using `reghdfe`, with interactions between
treatment and year. The base year is 2017. It includes propensity score
weights, multiple fixed effects, and joint F-tests on pre-trend years.
The script also generates graphs combining dynamic coefficients.

Inputs:
- db_robcheck.dta: Department-level panel data
- g01_DD_DynEff.do, g02_DDD_DynEff.do: Auxiliary graphing scripts

Outputs:
- Tables (commented-out): Tables_RC05_DynEff.[format]
- Figures: g01_RC05_DD_DynEff.png, g02_RC05_DDD_DynEff.png
==================================================================*/


* --------------------------------------------------
* Data Import
* --------------------------------------------------

use "${data_path}/db_robcheck.dta", clear


* --------------------------------------------------
* Table 1: DD with Year-by-Treatment Interactions
* --------------------------------------------------

cap est drop _all

foreach var of global y {

    * DD with dynamic treatment effects and baseline 2017
    qui reghdfe `var' ib0.treated##b2017.year $covar ///
        [pweight=w_ipw_pre], ///
        a(id treated i.uni_name_enc#i.year) cluster(id)

    * Joint test on pre-treatment years (2014–2016)
    test 1.treated#2014.year 1.treated#2015.year 1.treated#2016.year

    estadd scalar ftest = r(p)
    estadd local dptyear "Yes"
    estadd local contr "Yes"
    estadd local univyear "Yes"
    estadd local pscore "Yes"
    est store est3_`var'

}


/*
* --------------------------------------------------
* Table 1 - Panel A: DD Dynamic Effects Table
* --------------------------------------------------

esttab est3_* using "${output}/Tables_RC05_DynEff.${tab_fmt}", ///
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
        VA_percap "value added per capita") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore ftest N N_clust, labels( ///
        "Department and year FE" ///
        "Time-varying controls" ///
        "University-by-year FE" ///
        "Prop score weight" "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") ///
        fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Table 1} {Effect of DoE programme on faculty recruitment, new positions}) ///
    replace
*/


* --------------------------------------------------
* Figure 1: DD Dynamic Effects Graph
* --------------------------------------------------

do "${aux_path}/g01_DD_DynEff.do"

graph combine ///
    "${temp_path}/gr1.gph" "${temp_path}/gr2.gph" ///
    "${temp_path}/gr3.gph" "${temp_path}/gr4.gph", ///
    rows(2) xcommon ///
    l1("Effect of DoE programme", size(small)) ///
    b1("Year", size(small))

graph export "${output}/g01_RC05_DD_DynEff.png", replace width(10000)


* --------------------------------------------------
* Table 2: DDD with Dynamic Effects
* --------------------------------------------------

cap est drop _all

foreach var of global y {

    * DDD with LOWdep and dynamic year interactions
    qui reghdfe `var' ib0.treated##i.LOWdep##b2017.year $covar ///
        [pweight=w_ipw_pre], ///
        a(id treated i.uni_name_enc#i.year) cluster(id)

    * Joint test on pre-treatment years (2014–2016)
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


/*
* --------------------------------------------------
* Table 2 - Panel A: DDD Dynamic Effects Table
* --------------------------------------------------

esttab est3_* using "${output}/Tables_RC05_DynEff.${tab_fmt}", ///
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
        VA_percap "value added per capita") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats(dptyear contr univyear pscore ftest N N_clust, labels( ///
        "Department and year FE" "Time-varying controls" ///
        "University-by-year FE" "Prop score weight" "Joint p-value" ///
        "N (Departments X year)" "N (Departments)") ///
        fmt(0 0 0 0 3 0 0)) ///
    addnotes("Notes. This table displays the event study coefficient estimates of equation (1) using 2014-2020 data. Regressions are based on 2,023 department-year observations. Estimates in columns (2)-(4) include controls for the number of employees at t-1, the number of staff that transferred from one department to another,the public funding received from other sources and VA_percap. Standard errors clustered at the department level are in parentheses.") ///
    nogaps onecell ///
    title({\b Panel A} {DDD - Effect of DoE programme on hiring}) ///
    replace
*/


* --------------------------------------------------
* Figure 2: DDD Dynamic Effects Graph
* --------------------------------------------------

do "${aux_path}/g02_DDD_DynEff.do"

graph combine ///
    "${temp_path}/gr1.gph" "${temp_path}/gr2.gph" ///
    "${temp_path}/gr3.gph" "${temp_path}/gr4.gph", ///
    rows(2) xcommon ///
    l1("Effect of DoE programme", size(small)) ///
    b1("Year", size(small))

graph export "${output}/g02_RC05_DDD_DynEff.png", replace width(10000)
