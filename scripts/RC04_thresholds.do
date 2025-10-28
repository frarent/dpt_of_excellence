/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script evaluates the robustness of DDD estimates to changes in
the threshold that defines low-performing departments (`LOWdep`). A
set of binary indicators representing alternative cutoffs (e.g., 95th,
96th, 97.5th percentiles) is iteratively applied. DDD regressions are
estimated with fixed effects and propensity score weights.

Inputs:
- db_robcheck.dta: Panel data with alternative LOWdep definitions.

Outputs:
- table_RC04_thres_[name].[format]: DDD result tables for each threshold.
==================================================================*/


* --------------------------------------------------
* Figure/Table 2.X: Threshold Sensitivity - LOWdep
* --------------------------------------------------
* others such as ispd_alto_95_5 ispd_alto_96 ///
                ispd_alto_96mezzo ispd_alto_97 ///
                ispd_alto_97mezzo ispd_alto_98mezzo ///
                ispd_alto_99 yield similar results
				
foreach name in ispd_alto_95  {

    * Load full dataset
    use "${data_path}/db_robcheck.dta", clear

    * Redefine LOWdep based on current threshold indicator
    replace LOWdep = 1 if `name' == 0
    replace LOWdep = 0 if `name' == 1

    cap est drop _all

    foreach var of global y {

        * Run DDD with updated LOWdep definition
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

    * Export results table for current threshold definition
    esttab est3_* using "${output}/table_RC04_thres_`name'.${tab_fmt}", ///
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
        title({\b Table XXX} {"Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments, 40th percentile threshold"}) ///
        replace

}
