* -------------------------------------------------------------
* REPLICATE THE DOCX DESCRIPTIVE TABLE AS HTML
* -------------------------------------------------------------
* Assumptions:
* - treated == 1/0 (treated/control)
* - LOWdep == 1 for "second-tier", 0 for "first-tier"
* - Variable labels are set sensibly; we override below to match the DOCX text exactly.
* - $covar includes the controls used below (adjust names if needed).
* -------------------------------------------------------------

* 0) Setup and sample
use "${data_path}/db_robcheck.dta", clear

* define outcome variables (your set)
global y new_position new_entry new_endogamia new_rtda new_rtdb new_ten_uni_all

* main regression to define analytical sample
qui reghdfe new_position ib0.treated##i.post2 $covar [pweight=w_ipw_pre], ///
    absorb(id i.uni_name_enc#i.post2) vce(cluster id)
keep if e(sample)

* scale research funding to millions (as in your workflow)
capture confirm variable tot_premiale
if !_rc replace tot_premiale = tot_premiale/1000000

* 1) Put variables in the exact row order shown in the DOCX
local depvars  new_position new_entry new_endogamia new_rtda new_rtdb new_ten_uni_all
* EDIT the control names below to match your dataset (keep this order):
* # researchers ; # of transfers ; research funding (mil €) ; value added per capita ; unemployment rate
local ctrls    lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate



* 2) Compute summary stats for each column (listwise so N matches the table's single N per column)
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

estpost summarize `depvars' `ctrls' if treated==1 & LOWdep==1, listwise
eststo tr_sec

estpost summarize `depvars' `ctrls' if treated==1 & LOWdep==0, listwise
eststo tr_fst

estpost summarize `depvars' `ctrls' if treated==0 & LOWdep==1, listwise
eststo ct_sec

estpost summarize `depvars' `ctrls' if treated==0 & LOWdep==0, listwise
eststo ct_fst


    

* 3) Export HTML with mean on top and (SD) on the next line; column labels & numbering as in the DOCX
esttab overall tr ct sec fst tr_sec tr_fst ct_sec ct_fst using "${output}/overall.html", ///
    replace style(html) label noobs nonumber collabels(none) ///
    mtitle("overall (1)" "treated (2)" "untreated (3)" "second-tier (4)" "first-tier (5)" ///
           "treated second-tier (6)" "treated first-tier (7)" "untreated second-tier (8)" "untreated first-tier (9)") ///
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
        lagi       "# researchers" ///
        dep_transfer_horizontal           "# of transfers" ///
        tot_premiale        "research funding (mil &euro;)" ///
        VA_percap               "value added per capita" ///
        unemp_rate               "unemployment rate" ///
    ) ///
    refcat(new_position "Dependent variables" lagi "Control variables", nolabel)
