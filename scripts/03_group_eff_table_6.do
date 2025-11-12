* --------------------------------------------------
* Project: Beyond the Badge of Honour: The Effect of
* the Italian (Department of) Excellence Initiative
* on Staff Recruitment
* Author: Francesco Rentocchini and Ugo Rizzo
* Date: 12 Nov 2025
*
* Code Description
* - Purpose: Estimate fully interacted DDD models with contrasts on staff
*   recruitment outcomes using inverse-probability weights and high-dim FE.
*	report DDD contrasts in a table
* - Data inputs: ${data_path}/data_for_analysis.dta
* - Expected outputs: ${output}/Table_06.csv (custom CSV table with DDD
*   contrasts, SEs, p-values, and N of departments)
* --------------------------------------------------

* --------------------------------------------------
* Globals & locals (SET GLOBALS AND LOCALS FOR ANALYSIS)
* --------------------------------------------------

global covar lagi dep_transfer_horizontal tot_premiale VA_percap ///
    unemp_rate

global y new_position new_entry new_endogamia new_rtda ///
    new_rtdb new_ten_uni_all

use "${data_path}/data_for_analysis.dta", clear

* --------------------------------------------------
* Fully Interacted DDD with Contrasts
* (stores key contrasts via estadd; keeps N of departments)
* --------------------------------------------------
foreach var of global y {
    qui reghdfe `var' i.treated##i.post2##i.LOWdep $covar ///
        [pweight=w_ipw_pre], ///
        a(id i.post2 i.uni_name_enc#i.post2) cluster(id)

    * Column 1: Treat × Post × Second-tier (main DDD coefficient)
    * This is the coefficient on 1.treated#1.post2#1.LOWdep
    estadd scalar b_col1 = _b[1.treated#1.post2#1.LOWdep]
    estadd scalar se_col1 = _se[1.treated#1.post2#1.LOWdep]
    test 1.treated#1.post2#1.LOWdep = 0
    estadd scalar p_col1 = r(p)

    * Column 2: Second-tier Funded vs Non-funded (treated=1, LOW=1 vs LOW=0)
    * T vs NT | LOW = 1
    di in red "++++ `var' Col 2: Second-tier Funded vs Non-funded +++++"
    lincom _b[1.treated#1.LOWdep#1.post2] + _b[1.treated#1.post2]
    estadd scalar b_col2 = r(estimate)
    estadd scalar se_col2 = r(se)
    estadd scalar p_col2 = r(p)

    * Column 3: First-tier Funded vs Non-funded (treated=1, LOW=0)
    * T vs NT | LOW = 0
    di in red "++++ `var' Col 3: First-tier Funded vs Non-funded +++++"
    lincom _b[1.treated#1.post2]
    estadd scalar b_col3 = r(estimate)
    estadd scalar se_col3 = r(se)
    estadd scalar p_col3 = r(p)

    * Column 4: Funded Second-tier vs First-tier (treated=1)
    * LOW vs HIGH | T = 1
    di in red "++++ `var' Col 4: Funded Second-tier vs First-tier +++++"
    lincom _b[1.treated#1.LOWdep#1.post2] + _b[1.LOWdep#1.post2]
    estadd scalar b_col4 = r(estimate)
    estadd scalar se_col4 = r(se)
    estadd scalar p_col4 = r(p)

    * Column 5: Non-funded Second-tier vs First-tier (treated=0)
    * LOW vs HIGH | T = 0
    di in red "++++ `var' Col 5: Non-funded Second-tier vs First-tier +++++"
    lincom _b[1.LOWdep#1.post2]
    estadd scalar b_col5 = r(estimate)
    estadd scalar se_col5 = r(se)
    estadd scalar p_col5 = r(p)

    * Store N (departments)
    qui distinct id if e(sample)
    estadd scalar N_dept = r(ndistinct)

    est store est_`var'
}

* --------------------------------------------------
* Manual table construction for exact formatting
* (CSV headers, rows: coefficients with stars, SEs, N)
* --------------------------------------------------
cap file close mytable
file open mytable using "${output}/Table_06.csv", write replace

* Write headers
file write mytable "" ///
    ",Treat X Post X Second-tier" ///
    ",Second-tier Funded vs Non-funded" ///
    ",First-tier Funded vs Non-funded" ///
    ",Funded Second-tier vs First-tier" ///
    ",Non-funded Second-tier vs First-tier" ///
    ",N (Departments)" _n

file write mytable "" ///
    ",[1],[2],[3],[4],[5]," _n

* Loop through each outcome variable
local varlist "new_position new_entry new_endogamia new_rtda new_rtdb new_ten_uni_all"
local varlabels `" "New positions" "New positions (excl. promotions)" "Internal promotions" "Temporary" "Tenure track" "Tenured" "'

local i = 1
foreach var of local varlist {
    local vlab : word `i' of `varlabels'

    * Get stored estimates
    qui est restore est_`var'

    * Extract coefficients and SEs
    local b1 = e(b_col1)
    local se1 = e(se_col1)
    local p1 = e(p_col1)

    local b2 = e(b_col2)
    local se2 = e(se_col2)
    local p2 = e(p_col2)

    local b3 = e(b_col3)
    local se3 = e(se_col3)
    local p3 = e(p_col3)

    local b4 = e(b_col4)
    local se4 = e(se_col4)
    local p4 = e(p_col4)

    local b5 = e(b_col5)
    local se5 = e(se_col5)
    local p5 = e(p_col5)

    local n_dept = e(N_dept)

    * Add significance stars
    local star1 = ""
    if `p1' < 0.01 local star1 = "**"
    else if `p1' < 0.05 local star1 = "*"
    else if `p1' < 0.1 local star1 = "+"

    local star2 = ""
    if `p2' < 0.01 local star2 = "**"
    else if `p2' < 0.05 local star2 = "*"
    else if `p2' < 0.1 local star2 = "+"

    local star3 = ""
    if `p3' < 0.01 local star3 = "**"
    else if `p3' < 0.05 local star3 = "*"
    else if `p3' < 0.1 local star3 = "+"

    local star4 = ""
    if `p4' < 0.01 local star4 = "**"
    else if `p4' < 0.05 local star4 = "*"
    else if `p4' < 0.1 local star4 = "+"

    local star5 = ""
    if `p5' < 0.01 local star5 = "**"
    else if `p5' < 0.05 local star5 = "*"
    else if `p5' < 0.1 local star5 = "+"

    * Write coefficient row
    file write mytable "`vlab'" ///
        "," %4.3f (`b1') "`star1'" ///
        "," %4.3f (`b2') "`star2'" ///
        "," %4.3f (`b3') "`star3'" ///
        "," %4.3f (`b4') "`star4'" ///
        "," %4.3f (`b5') "`star5'" ///
        "," (`n_dept') _n

    * Write standard error row
    file write mytable "" ///
        ",[" %4.3f (`se1') "]" ///
        ",[" %4.3f (`se2') "]" ///
        ",[" %4.3f (`se3') "]" ///
        ",[" %4.3f (`se4') "]" ///
        ",[" %4.3f (`se5') "]" ///
        "," _n

    local i = `i' + 1
}

file close mytable