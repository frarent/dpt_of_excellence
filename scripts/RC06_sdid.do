/*==================================================================
Author: Francesco Rentocchini
Current Date: 21 April 2025
Project Name: Department of Excellence Project

Code Description:
This script estimates treatment effects using the Synthetic Difference-
in-Differences (SDID) method by Arkhangelsky et al. (2021), both in a 
standard DD and in a DDD setup. The script computes ATT estimates 
separately for LOWdep groups and combines results to evaluate 
heterogeneous treatment effects.

Outputs include:
- Individual outcome SDID graphs
- Grouped SDID plots (Panel Figures)
- Summary table of DDD estimates across outcomes

Inputs:
- db_robcheck.dta
==================================================================*/

*covariates($covar , projected)

* --------------------------------------------------
* SDID DD ESTIMATES AND GRAPHS
* --------------------------------------------------

*macro
global reps 1000

use "${data_path}/db_robcheck.dta", clear


* Generate treatment indicator from 2018 onward
gen treat_from2018 = treated
replace treat_from2018 = 0 if treated == 1 & year < 2018

* Keep relevant years and variables
keep id year treat_from2018 $y $covar
keep if year > 2013

* Drop unbalanced panels due to missing vars
egen flag_miss = rowmiss($y $covar treat_from2018)
bysort id: egen flag_miss2 = total(flag_miss)
drop if flag_miss2 == 1
drop flag_miss*


* Label outcomes
label var new_position "# of new positions"
label var new_entry "# of new positions (excl. promotions)"
label var new_rtda "# of new temporary positions"
label var new_rtdb "# of new tenure track positions"
label var new_ten_uni_all "# of new tenured positions"
label var new_endogamia "# of internal promotions"


* Estimate SDID and generate graphs
foreach var of global y {

    sdid `var' id year treat_from2018, ///
        vce(bootstrap) covariates($covar) ///
        reps(${reps}) seed(123) ///
        graph

    matrix A = e(series)
    matrix w = e(lambda)
    matrix w2 = w[1..4,1]
    matrix rownames A = 2014 2015 2016 2017 2018 2019 2020
    matrix rownames w2 = 2014 2015 2016 2017
    coefplot (matrix(A[,2]), lpattern("dash") label("Control")) ///
        (matrix(A[,3]), label("Treated")) ///
        (matrix(w2[,1]), recast(bar) color(%30) label("Lambda weights")), ///
        vertical nooffsets recast(line) xline(4.5) ///
        ytitle("`: variable label `var''", size(vsmall)) ///
        legend(rows(1) pos(6)) ///
        note( "ATT = `: display %-5.3f e(ATT)'" ///
		"SE = [`: display %-5.3f e(se)']", span size(.2cm))

    graph save "${temp_path}/gr_`var'.gph", replace
}


* --------------------------------------------------
* Combined Graph Panels
* --------------------------------------------------

* Panel 1: Core hiring outcomes
grc1leg "${temp_path}/gr_new_position.gph" ///
    "${temp_path}/gr_new_entry.gph" ///
    "${temp_path}/gr_new_endogamia.gph", ///
    cols(2) imargin(1 1 1) xcommon ///
    legendfrom("${temp_path}/gr_new_position.gph") ///
    ring(1) position(6) ///
    note("Notes. Synthetic Difference-in-Difference estimator (Arkhangelsky et al., 2021). Include controls for the number of employees at t-1, the number of staff that transferred from one department to another, the public funding received from other sources and VA_percap. Standard errors are based on 1000 bootstrap replications.", span size(.15cm))

graph export "${output}/g03_RC06_DD_sdid1.png", replace width(10000)


* Panel 2: Temporary and tenured tracks
grc1leg "${temp_path}/gr_new_rtda.gph" ///
    "${temp_path}/gr_new_rtdb.gph" ///
    "${temp_path}/gr_new_ten_uni_all.gph", ///
    cols(2) imargin(1 1 1) xcommon ///
    legendfrom("${temp_path}/gr_new_rtda.gph") ///
    ring(1) position(6) ///
    note("Notes. Synthetic Difference-in-Difference estimator (Arkhangelsky et al., 2021). Include controls for the number of employees at t-1, the number of staff that transferred from one department to another, the public funding received from other sources and VA_percap. Standard errors are based on 1000 bootstrap replications.", span size(.15cm))

graph export "${output}/g04_RC06_DD_sdid2.png", replace width(10000)


* Panel 3: All outcomes (combined)
grc1leg "${temp_path}/gr_new_position.gph" ///
    "${temp_path}/gr_new_entry.gph" ///
    "${temp_path}/gr_new_endogamia.gph" ///
    "${temp_path}/gr_new_rtda.gph" ///
    "${temp_path}/gr_new_rtdb.gph" ///
    "${temp_path}/gr_new_ten_uni_all.gph", ///
    cols(2) imargin(1 1 1) xcommon ///
    legendfrom("${temp_path}/gr_new_position.gph") ///
    ring(1) position(6)

graph export "${output}/g04_RC06_DD_sdid_joint.png", replace width(10000)


* --------------------------------------------------
* SDID DDD ESTIMATES
* --------------------------------------------------

use "${data_path}/db_robcheck.dta", clear


* Treatment begins in 2018
gen treat_from2018 = treated
replace treat_from2018 = 0 if treated == 1 & year < 2018

keep id year treat_from2018 $y $covar LOWdep
keep if year > 2013

egen flag_miss = rowmiss($y $covar treat_from2018 LOWdep)
bysort id: egen flag_miss2 = total(flag_miss)
drop if flag_miss2 == 1
drop flag_miss*


* Label outcome variables
label var new_position "# of new positions"
label var new_entry "# of new positions (excl. promotions)"
label var new_rtda "# of new temporary positions"
label var new_rtdb "# of new tenure track positions"
label var new_ten_uni_all "# of new tenured positions"
label var new_endogamia "# of internal promotions"



* Create result matrix
matrix A = J(3, 9, .)

local i 0
foreach var of global y {
    local ++i

    * ATT for LOW = 1
    sdid `var' id year treat_from2018 if LOWdep == 1, ///
        vce(bootstrap) covariates($covar) ///
        reps(${reps}) seed(123)
    local att_low = e(ATT)
    local se_low  = e(se)

    * ATT for LOW = 0
    sdid `var' id year treat_from2018 if LOWdep == 0, ///
        vce(bootstrap) covariates($covar) ///
        reps(${reps}) seed(123)
    local att_high = e(ATT)
    local se_high  = e(se)

    * Compute DDD contrast
    local att_ddd = (`att_low' - `att_high')
    local se_ddd  = sqrt(`se_low'^2 + `se_high'^2)
    local z_ddd   = `att_ddd'/`se_ddd'
    local p_ddd   = 2*(1 - normal(abs(`z_ddd')))

    matrix A[1,`i'] = `att_ddd'
    matrix A[2,`i'] = `se_ddd'
    matrix A[3,`i'] = `p_ddd'
}


matrix colnames A = "# of new positions" ///
    "# of new pos excl promotions" "# of internal promotions" ///
	"# of new temporary positions" ///
    "# of new tenure track positions" "# of new tenured positions"
    

matrix rownames A = "ATT" "Std Err" "p-value"
matrix A = A[., 1..6]

* Export summary table
esttab matrix(A, fmt(3 3 3)) using ///
    "$output/table_RC06_DDD_sdid.${tab_fmt}", ///
    replace unstack align(center) nomtitles se ///
    note("SE are bootstraped 1000 reps")
