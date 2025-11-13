* ====================================================================
* Author: Francesco Rentocchini and Ugo Rizzo
* Current Date: 2025-11-12
* Project Name: Beyond the Badge of Honour: The Effect of the Italian
* (Department of) Excellence Initiative on Staff Recruitment
* 
* Code Description:
*   Purpose: Produce Table 1 summary statistics for the paper. The code
*   defines the analytical sample via a weighted reghdfe regression,
*   scales funding to millions, orders variables, computes means/SDs for
*   the full sample and key sub-samples, and exports an esttab table.
* 
*   Data inputs: ${raw_data_path}/data_for_analysis.dta.
*   Expected outputs: ${output}/Table_01.${tab_fmt} (esttab table).
* 
* ====================================================================

* --------------------------------------------------
* Data Import: Load analysis dataset.
* --------------------------------------------------

use "${raw_data_path}/data_for_analysis.dta", clear

* --------------------------------------------------
* Setup: Globals and locals for analysis.
* --------------------------------------------------

global covar lagi dep_transfer_horizontal tot_premiale VA_percap ///
    unemp_rate
global y new_position new_entry new_endogamia new_rtda new_rtdb ///
    new_ten_uni_all	

* --------------------------------------------------
* Analytical Sample: Define via main regression and keep e(sample).
* --------------------------------------------------

* Main regression to define analytical sample
qui reghdfe new_position ib0.treated##i.post2 $covar [pweight=w_ipw_pre], ///
    absorb(id i.uni_name_enc#i.post2) vce(cluster id)
keep if e(sample)

* --------------------------------------------------
* Transformations: Scale research funding to millions.
* --------------------------------------------------

* Scale research funding to millions
capture confirm variable tot_premiale
if !_rc replace tot_premiale = tot_premiale/1000000

* --------------------------------------------------
* Variable Order: Locals for dependent vars and controls.
* --------------------------------------------------

* Put variables in the exact order
local depvars  new_position new_entry new_endogamia new_rtda new_rtdb ///
    new_ten_uni_all
* # researchers ; # of transfers ; research funding (mil €) ; value added
* per capita ; unemployment rate
local ctrls    lagi dep_transfer_horizontal tot_premiale VA_percap ///
    unemp_rate

* --------------------------------------------------
* Summary Statistics: Compute overall and subgroup means/SDs.
* --------------------------------------------------

* Compute summary stats for each column
eststo clear
estpost summarize `depvars' `ctrls', listwise
eststo overall

estpost summarize `depvars' `ctrls' if treated==1, listwise
eststo tr

estpost summarize `depvars' `ctrls' if treated==0, listwise
eststo ct

estpost summarize `depvars' `ctrls' if LOWdep==1, listwise
eststo sec

estpost summarize `depvars' `ctrls' if LOWdep==0, listwise
eststo fst

estpost summarize `depvars' `ctrls' if treated==1 & LOWdep==1, ///
    listwise
eststo tr_sec

estpost summarize `depvars' `ctrls' if treated==1 & LOWdep==0, ///
    listwise
eststo tr_fst

estpost summarize `depvars' `ctrls' if treated==0 & LOWdep==1, ///
    listwise
eststo ct_sec

estpost summarize `depvars' `ctrls' if treated==0 & LOWdep==0, ///
    listwise
eststo ct_fst

* --------------------------------------------------
* Table Output: Export esttab summary statistics table.
* --------------------------------------------------

esttab overall tr ct sec fst tr_sec tr_fst ct_sec ct_fst using ///
    "${output}/Table_01.${tab_fmt}", replace style(html) label noobs ///
    nonumber collabels(none) mtitle("overall (1)" "treated (2)" ///
    "untreated (3)" "second-tier (4)" "first-tier (5)" ///
    "treated second-tier (6)" "treated first-tier (7)" ///
    "untreated second-tier (8)" "untreated first-tier (9)") ///
    cells("mean(fmt(2)) sd(par fmt(2))") ///
    stats(N, labels("Observations") fmt(0)) ///
    addnotes("Notes. Table shows summary statistics for the full sample (column 1) and for several sub-samples. Sub-samples are: treated (column 2) and untreated (column 3) departments, second- (column 4) and first-tier departments (column 5), treated second – (column 6) and treated first-tier departments (column 7), untreated second – (column 8) and untreated first-tier departments (column 9). Summary statistics are means and standard deviations (in parentheses).") ///
    title("Table 1: Summary statistics, full sample and sub-samples") ///
    varlabels( ///
        new_position        "New positions" ///
        new_entry           "New positions (excl. promotions)" ///
        new_endogamia       "Internal promotions" ///
        new_rtda            "Temporary" ///
        new_rtdb            "Tenure track" ///
        new_ten_uni_all     "Tenured" ///
        lagi                "# researchers" ///
        dep_transfer_horizontal "# of transfers" ///
        tot_premiale        "research funding (mil &euro;)" ///
        VA_percap           "value added per capita" ///
        unemp_rate          "unemployment rate" ///
    ) ///
    refcat(new_position "Dependent variables" lagi "Control variables", ///
    nolabel)
