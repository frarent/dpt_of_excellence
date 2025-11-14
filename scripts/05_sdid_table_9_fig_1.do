* --------------------------------------------------
* Project: Beyond the Badge of Honour: The Effect of
* the Italian (Department of) Excellence Initiative
* on Staff Recruitment
* Author: Francesco Rentocchini and Ugo Rizzo
* Date: 12 Nov 2025
*
* Code Description
* - Purpose: Estimate SDID DD and DDD effects and produce figures/tables.
* - Data inputs: ${raw_data_path}/data_for_analysis.dta
* - Expected outputs:
*   - ${temp_path}/gr_<outcome>.gph (per-outcome graphs)
*   - ${output}/Figure_01.png (combined figure)
*   - ${output}/Table_09.${tab_fmt} (SDID DDD summary table)
* --------------------------------------------------

* --------------------------------------------------
* Globals & locals (SET GLOBALS AND LOCALS FOR ANALYSIS)
* --------------------------------------------------

global covar lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate

global y new_position new_entry new_endogamia new_rtda new_rtdb new_ten_uni_all	

global reps 500 // number of bootstrap replications




* --------------------------------------------------
* SDID DD ESTIMATES AND GRAPHS
* --------------------------------------------------
preserve
	use "${raw_data_path}/data_for_analysis.dta",clear

	label var new_position "New positions"
	label var new_entry "New positions (excl. promotions)"
	label var new_endogamia "Internal promotions"
	label var new_rtda "Temporary"
	label var new_rtdb "Tenure track"
	label var new_ten_uni_all "Tenured"


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

	* Estimate SDID and generate graphs
	foreach var of global y {
		sdid `var' id year treat_from2018, ///
			vce(bootstrap) covariates($covar) ///
			reps(${reps}) seed(150749) ///
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
	* Combined Graph
	* --------------------------------------------------


	* All outcomes (combined)
	grc1leg "${temp_path}/gr_new_position.gph" ///
		"${temp_path}/gr_new_entry.gph" ///
		"${temp_path}/gr_new_endogamia.gph" ///
		"${temp_path}/gr_new_rtda.gph" ///
		"${temp_path}/gr_new_rtdb.gph" ///
		"${temp_path}/gr_new_ten_uni_all.gph", ///
		cols(2) imargin(1 1 1) xcommon ///
		legendfrom("${temp_path}/gr_new_position.gph") ///
		ring(1) position(6) ///
		note("Synthetic Difference-in-Difference estimator (Arkhangelsky et al., 2021). Estimates include controls for the number of employees at t-1, the number of staff transferred between departments," ///
		"university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Lambda weights are shown in grey and are defined as optimized time weights assigned" ///
		"to control units to construct the synthetic control that minimize the differences with the treated unit during the pre-treatment period. Standard errors are based on 500 bootstrap replications. ", span size(.15cm))

	graph export "${output}/Figure_01.png", replace width(10000)

restore

* --------------------------------------------------
* SDID DDD ESTIMATES
* --------------------------------------------------

use "${raw_data_path}/data_for_analysis.dta",clear



* Generate treatment indicator from 2018 onward
gen treat_from2018 = treated
replace treat_from2018 = 0 if treated == 1 & year < 2018

* Keep relevant years and variables
keep id year treat_from2018 $y $covar LOWdep
keep if year > 2013

* Drop observations to square the panel
egen flag_miss = rowmiss($y $covar treat_from2018 LOWdep)
bysort id: egen flag_miss2 = total(flag_miss)
drop if flag_miss2 == 1
drop flag_miss*



* Create result matrix
matrix A = J(3, 9, .)

* Sdid estimates
local i 0
foreach var of global y {
    local ++i 
    * ATT for LOW = 1
    sdid `var' id year treat_from2018 if LOWdep == 1, ///
        vce(bootstrap) covariates($covar) ///
        reps(${reps}) seed(150749)
    local att_low = e(ATT)
    local se_low  = e(se)

    * ATT for LOW = 0
    sdid `var' id year treat_from2018 if LOWdep == 0, ///
        vce(bootstrap) covariates($covar) ///
        reps(${reps}) seed(150749)
    local att_high = e(ATT)
    local se_high  = e(se)

    * Compute DDD contrast
    local att_ddd = (`att_low' - `att_high')
    local z_ddd   = `att_ddd'/`se_ddd'
    local p_ddd   = 2*(1 - normal(abs(`z_ddd')))

    matrix A[1,`i'] = `att_ddd'
    matrix A[2,`i'] = `se_ddd'
    matrix A[3,`i'] = `p_ddd'
}


    
* Assemble and label matrix contatining results
matrix A = A[., 1..6]
distinct id
matrix B =[r(ndistinct),r(ndistinct),r(ndistinct) ,r(ndistinct) ,r(ndistinct) ,r(ndistinct)]
matrix A=[A\B]
matrix colnames A = "New positions" ///
    "New positions (excl promotions)" "Internal promotions" ///
	"Temporary" ///
    "Tenure track" "Tenured"
matrix rownames A = "ATT" "Std Err" "p-value" "N(Departments)"


* --------------------------------------------------
* Export summary table
* --------------------------------------------------
esttab matrix(A, fmt(3 3 3 3 3 3)) using ///
    "$output/Table_09.${tab_fmt}", ///
    replace unstack align(center) nomtitles se ///
	title("Table 9: Effect of the Department of Excellence Programme on University Faculty Recruitment for second tier university departments: Synthetic Diff-in-Diff estimator") ///
    addnotes("Notes: this table displays results from the synthetic difference-in-difference estimator (Arkhangelsky et al., 2021), based on 2,023 department-year observations using 2014-2020 data. Estimates include controls for the number of employees at t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added and provincial unemployment rate. Standard errors are based on 500 bootstrap replications.")

drop treat_from2018
