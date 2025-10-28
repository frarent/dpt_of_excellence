
use "${data_path}/db_robcheck.dta",clear

global y new_position	new_entry new_endogamia 	new_rtda	new_rtdb	new_ten_uni_all	



	
	qui reghdfe new_position  ib0.treated##i.post2 $covar [pweight=w_ipw_pre], ///
	a(id i.uni_name_enc#i.post2) cluster(id)

keep if e(sample)



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

replace tot_premiale=tot_premiale/1000000


foreach var of varlist $y $covar {
	dis in red "`var'"
	ttest `var',by(treated)
}

foreach var of varlist $y $covar {
	dis in red "`var'"
	ttest `var',by(LOWdep)
}


foreach var of varlist $y $covar {
	dis in red "`var'"
	ttest `var' if treated==1,by(LOWdep)
}

foreach var of varlist $y $covar {
	dis in red "`var'"
	ttest `var' if treated==0,by(LOWdep)
}


foreach var of varlist $y $covar {
	dis in red "`var'"
	ttest `var' if LOWdep==1,by(treated)
}

foreach var of varlist $y $covar {
	dis in red "`var'"
	ttest `var' if LOWdep==0,by(treated)
}

bysort id: gen dpt=_n
replace dpt=. if dpt!=1

estpost tabstat $y $covar dpt , c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) replace
 
estpost tabstat $y $covar dpt if treated==1, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if treated==0, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if LOWdep==1, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if LOWdep==0, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if treated==1&LOWdep==1, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if treated==1&LOWdep==0, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if treated==0&LOWdep==1, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

estpost tabstat $y $covar dpt if treated==0&LOWdep==0, c(s) s(mean sd n)
esttab . using "$output/des.csv", cells("mean(fmt(%9.2f))" "sd(par fmt(%9.2f))" "count") label varwidth(50) append

