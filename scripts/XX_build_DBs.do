/*
*=============================================================================*
* Project title: Beyond the Badge of Honour: The Effect of the Italian 
*	(Department of) Excellence Initiative on Staff Recruitment 
* Created by: Francesco Rentocchini and Ugo Rizzo
* Original Date: 21/03/2024
* Last Update: 11/3/2025
----------------------------------------------------------------------
Code Description:
- This script prepares panel data for estimation in the Department of
  Excellence project. It includes variable transformations,
  regional classifications, and construction of treatment indicators.
- Data input: data2estimate.dta (raw panel data)
- Output: db_before_est.dta (ready for estimation)
======================================================================
*/


// SET GLOBALS FOR ANALYSIS
*=============================================================================*

global covar lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate

// RESIDUAL DATA IMPORT
*=============================================================================*


import delimited "${raw_data_path}/Dati provinciali (IT1,151_914_DF_DCCV_TAXDISOCCU1_8,1.0).csv", bindquote(nobind) clear 
keep territorio time_period osservazione
rename territorio provincia
replace provincia=upper(provincia)
rename time_period year
rename osservazione unemp_rate

duplicates drop 
tempfile un1
save `un1'

*** ***

import delimited "${raw_data_path}/Dati provinciali (IT1,151_1193_DF_DCCV_TAXDISOCCU1_UNT2020_7,1.0).csv", bindquote(nobind) clear 
keep territorio time_period osservazione
rename territorio provincia
replace provincia=upper(provincia)
rename time_period year
rename osservazione unemp_rate

duplicates drop 
append using `un1'
duplicates drop provincia year, force

replace provincia=subinstr(provincia, `"""', "", .)

replace provincia="REGGIO CALABRIA" if provincia=="REGGIO DI CALABRIA"
replace provincia="L'AQUILA" if provincia=="'L'AQUILA'"

merge 1:m provincia year using "${raw_data_path}/data2estimate.dta", nogen keep(match)

save "${raw_data_path}/data2estimate1.dta", replace



* --------------------------------------------------
* Data Import and Panel Setup
* --------------------------------------------------

use "${raw_data_path}/data2estimate1.dta", clear
xtset id year

bysort id: gen n = _n


* --------------------------------------------------
* Regional Classification
* --------------------------------------------------

gen region = "North" if nord == 1
replace region = "Centre" if centro == 1
replace region = "South" if sud == 1

gen ripartizione = 1 if nord == 1
replace ripartizione = 2 if centro == 1
replace ripartizione = 3 if sud == 1

label define ripartizione 1 "North" 2 "Centre" 3 "South"


* --------------------------------------------------
* Variable Scaling
* --------------------------------------------------

replace VA_percap = VA_percap / 10000
replace pop1gen = pop1gen / 10000


* --------------------------------------------------
* Regression Variables Construction
* --------------------------------------------------

***** variables for regressions ****

gen LOWdep = 1 if ispd_alto == 0
replace LOWdep = 0 if ispd_alto == 1

gen post2 = 1 if year >= 2018 & year <= 2020
replace post2 = 0 if year >= 2014 & year <= 2017

gen treated_LOW = treated * LOWdep
gen policy_treated = policy * treated
gen policy_LOW = policy * LOWdep
gen tripleLOW = policy * treated * LOWdep


* --------------------------------------------------
* Transfer Share and Filtering
* --------------------------------------------------

gen g = dep_transfer_horizontal
replace g = 0 if year == 2013

bysort id: egen max_tran = max(g)
sum max_tran, d
tab max_tran

gen h = g / i
bysort id: egen max_sh_tran = max(h)
sum max_sh_tran, d
tab max_sh_tran
drop if max_sh_tran > 0.2


* --------------------------------------------------
* Growth and Log Variables
* --------------------------------------------------

egen t = group(year)
gen lagi = l.i

xtset id year
gen ln_i = ln(i)
xtset id year
gen gr_i = ln_i - l.ln_i


* --------------------------------------------------
* Global Macros and Encoding
* --------------------------------------------------

global w lagi

encode uni_name, g(uni_name_enc)
encode zonageografica, g(zonageografica_enc)

compress
save "${temp_path}/db_propscore.dta", replace


* --------------------------------------------------
* Pre-treatment Matching Weights
* --------------------------------------------------

use "${temp_path}/db_propscore.dta", clear

bysort id: gen y_flag = 1 if year >= 2014 & year <= 2017

foreach var of global covar {
    bysort id: egen `var'_pre = mean(`var') if y_flag == 1
}

logit treated *_pre i.zonageografica_enc
predict yhat

// weighting both T and NT groups
g temp = 1 / yhat if treated == 1
replace temp = 1 / (1 - yhat) if treated == 0

* normalising by group average
sum temp if treated == 0
gen ipw = temp / `r(mean)' if treated == 0
sum ipw if treated == 0

sum temp if treated == 1
replace ipw = temp / `r(mean)' if treated == 1
sum ipw if treated == 1


* same weight (built in the pre-treatment period) along the timeline
drop *_pre
bysort id: egen w_ipw_pre = mean(ipw)

cap drop y_flag ipw temp yhat

drop post2

* --------------------------------------------------
* Labels
* --------------------------------------------------

label var new_position "New positions"
label var new_entry "New positions (excl. promotions)"
label var new_endogamia "Internal promotions"

label var new_rtda "Temporary"
label var new_rtdb "Tenure track"
label var new_ten_uni_all "Tenured"

label var new_ten_uni_intern "# of new tenured internal"	
label var new_ten_uni_ext "# of new tenured external"
label var new_power "# of internal promotions to full prof"

label var lagi "# researchers -1"
label var dep_transfer_horizontal "# of transfers" 
label var tot_premiale "amount of research funding"
label var VA_percap "value added per capita"
label var unemp_rate "unemployment rate"



cap est drop _all

* Create post-treatment indicator for 2018–2020
gen post2 = 1 if year >= 2018 & year <= 2020
replace post2 = 0 if year >= 2014 & year <= 2017

keep id year ///
	new_position new_entry new_endogamia new_rtda new_rtdb new_ten_uni_all ///
	treated post2  LOWdep ///
	lagi dep_transfer_horizontal tot_premiale VA_percap unemp_rate ///
	w_ipw_pre uni_name_enc

* Label data and variables
label data "Italian Department of Excellence panel data 2013-2020"
label variable new_position "All new positions in the department; source: https://cercauniversita.cineca.it"
label variable new_entry "New positions in the department excluding internal promotions; source: https://cercauniversita.cineca.it"
label variable new_endogamia "New positions resulting from internal promotions; source: https://cercauniversita.cineca.it"
label variable new_rtda "Three-year fixed-term research positions (RTD-A in the Italian system); source: https://cercauniversita.cineca.it"
label variable new_rtdb "Three-year tenure-track research positions (RTD-B in the Italian system); source: https://cercauniversita.cineca.it"
label variable new_ten_uni_all "Tenured positions, i.e. Associate or Full Professorships; source: https://cercauniversita.cineca.it"
label variable treated "Treated departments: departments that received Department of Excellence funds; source: Ministry of University website"
label variable post2 "Years during which the Department of Excellence initiative is in place, i.e. from 2018 onwards"
label variable LOWdep "Second-tier departments: departments among the competitors with an ISPD score below the median; source: Ministry of University website"
label variable lagi "Number of researchers in the department in year t-1; source: https://cercauniversita.cineca.it"
label variable dep_transfer_horizontal "Number of researchers transferred from other departments within the same university; source: https://cercauniversita.cineca.it"
label variable tot_premiale "Amount of research funding received by the university based on the national research performance evaluation exercise (VQR); source: Ministry of University website"
label variable VA_percap "Per capita value added at the provincial level (NUTS 3 region); source: ISTAT"
label variable unemp_rate "Unemployment rate at the provincial level (NUTS 3 region); source: ISTAT"
label variable year "Year"
label variable id "Department identification number"
label variable uni_name_enc "Encoded university name"
label variable w_ipw_pre "Propensity score calculated controlling for the number of department research staff at time t-1, the number of staff transferred between departments, university income linked to the VQR, province-level per-capita value added, provincial unemployment rate and NUTS 1 regional fixed effects"

compress
save "${data_path}/data_for_analysis.dta", replace

* --------------------------------------------------
* Sanity Checks: Variable Means
* --------------------------------------------------

quietly summarize treated, meanonly
assert abs(r(mean) - 0.5103448) < 1e-5

quietly summarize LOWdep, meanonly
assert abs(r(mean) - 0.4862069) < 1e-5

quietly summarize post2, meanonly
assert abs(r(mean) - 0.4285714) < 1e-5
