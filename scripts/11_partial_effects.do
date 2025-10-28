/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script estimates a fully interacted DDD model with fixed effects 
and propensity score weights. It calculates conditional average 
treatment effects by subgroup (treated vs untreated, low vs high 
departments) using post-estimation `lincom` contrasts. Results are 
stored as scalars and summarized in a custom esttab table.

Inputs:
- db_robcheck.dta: Panel dataset with treatment status, LOWdep, 
  covariates, and weights

Outputs:
- table_03_PE_avg_DDD.[format]: DDD results table including lincom 
  contrasts and subgroup effects
==================================================================*/


* --------------------------------------------------
* Load Data
* --------------------------------------------------

use "${data_path}/db_robcheck.dta", clear

est drop _all


* --------------------------------------------------
* Fully Interacted DDD with Contrasts
* --------------------------------------------------

foreach var of global y {

    qui reghdfe `var' i.treated##i.post2##i.LOWdep $covar ///
        [pweight=w_ipw_pre], ///
        a(id i.post2 i.uni_name_enc#i.post2) cluster(id)

    * Treated vs Non-treated when LOWdep == 0
    di in red "++++ `var' T vs NT | LOW = 0 +++++"
    lincom _b[1.treated#1.post2]
    estadd scalar b_TvsNT_low0 = r(estimate)
    estadd scalar se_TvsNT_low0 = r(se)
    estadd scalar p_TvsNT_low0 = r(p)

    * Treated vs Non-treated when LOWdep == 1
    di in red "++++ `var' T vs NT | LOW = 1 +++++"
    lincom _b[1.treated#1.LOWdep#1.post2] + _b[1.treated#1.post2]
    estadd scalar b_TvsNT_low1 = r(estimate)
    estadd scalar se_TvsNT_low1 = r(se)
    estadd scalar p_TvsNT_low1 = r(p)

    * LOW vs High when Treated == 1
    di in red "++++ `var' LOW vs HIGH | T = 1 +++++"
    lincom _b[1.treated#1.LOWdep#1.post2] + _b[1.LOWdep#1.post2]
    estadd scalar b_LOWvsNLOW_T1 = r(estimate)
    estadd scalar se_LOWvsNLOW_T1 = r(se)
    estadd scalar p_LOWvsNLOW_T1 = r(p)

    * LOW vs High when Treated == 0
    di in red "++++ `var' LOW vs HIGH | T = 0 +++++"
    lincom _b[1.LOWdep#1.post2]
    estadd scalar b_LOWvsNLOW_T0 = r(estimate)
    estadd scalar se_LOWvsNLOW_T0 = r(se)
    estadd scalar p_LOWvsNLOW_T0 = r(p)

    est store est_`var'

}


* --------------------------------------------------
* Esttab Output: DDD + Custom Contrasts
* --------------------------------------------------

esttab $y1 $y2 using "${output}/table_03_PE_avg_DDD.${tab_fmt}", ///
    keep(1.treated#1.post2#1.LOWdep) ///
    starlevels(+ 0.1 * 0.05 ** 0.01) ///
    varlabels( ///
        1.treated#1.post2#1.LOWdep "Treat X Low X Post" ///
        lagi "# researchers -1" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale "amount of research funding" ///
        VA_percap "value added per capita" ///
		unemp_rate "unemployment rate") ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    legend collabels(, none) ///
    stats( ///
        b_TvsNT_low1 se_TvsNT_low1 p_TvsNT_low1 ///
        b_TvsNT_low0 se_TvsNT_low0 p_TvsNT_low0 ///
        b_LOWvsNLOW_T1 se_LOWvsNLOW_T1 p_LOWvsNLOW_T1 ///
        b_LOWvsNLOW_T0 se_LOWvsNLOW_T0 p_LOWvsNLOW_T0 ///
        N N_clust, labels( ///
            "T vs NT for LOW=1 (b)" "T vs NT for LOW=1 (se)" ///
            "T vs NT for LOW=1 (p)" ///
            "T vs NT for LOW=0 (b)" "T vs NT for LOW=0 (se)" ///
            "T vs NT for LOW=0 (p)" ///
            "LOW vs NO LOW for T=1 (b)" "LOW vs NO LOW for T=1 (se)" ///
            "LOW vs NO LOW for T=1 (p)" ///
            "LOW vs NO LOW for T=0 (b)" "LOW vs NO LOW for T=0 (se)" ///
            "LOW vs NO LOW for T=0 (p)" ///
            "N (Departments X year)" "N (Departments)") ///
        fmt(3 3 3 3 3 3 3 3 3 3 3 3 0 0)) ///
    nogaps onecell noomitted ///
	mtitles("New positions"	"New positions (excl. promotions)"	///
	"Internal promotions"	"Temporary"	"Tenure track"	"Tenured") ///
    title({\b Table XXX} {"Group effects"}) ///
    replace
