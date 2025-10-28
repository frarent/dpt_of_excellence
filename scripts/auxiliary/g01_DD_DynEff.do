coefplot $plot_y1, ///
	keep(1.treated#*.year) vertical ///
	omitted baselevels ///
	msymbol(d) ///
	ciopts(recast(rcap)) levels(95) ///
	coeflabels(1.treated#2014.year="2014" 1.treated#2015.year="2015" ///
	1.treated#2016.year="2016" 1.treated#2018.year="2018" 1.treated#2017.year="2017" 1.treated#2019.year="2019" ///
	1.treated#2020.year="2020") ///
	xline(5 6 7, lwidth(1.5cm) lpattern(solid) lcolor(gs15)) ///
	yline(0) ///
	title("",size(medsmall))  ///
	legend(rows(1) pos(6) ring(1) label(2 "# of new positions") label(4 "# of new positions (excl. promotions)"))


graph save "${temp_path}/gr1.gph",replace 

coefplot ///
	(est3_new_rtda, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("gs8") ///
	ciopts(recast(rcap) lcolor("gs8"))) ///
	(est3_new_rtdb, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("black") ///
	ciopts(recast(rcap) lcolor("black"))) ///
	, ///
	vertical levels(95) ///
	coeflabels(1.treated#2014.year="2014" 1.treated#2015.year="2015" ///
	1.treated#2016.year="2016" 1.treated#2018.year="2018" 1.treated#2017.year="2017" 1.treated#2019.year="2019" ///
	1.treated#2020.year="2020") ///
	xline(5 6 7, lwidth(1.5cm) lpattern(solid) lcolor(gs15)) ///
	yline(0) ///
	title("",size(medsmall))  ///
	legend(rows(1) pos(6) ring(1) label(2 "# of new temporary positions") label(4 "# of new tenure track positions"))
	
graph save "${temp_path}/gr2.gph",replace 


	
	
coefplot ///
	(est3_new_ten_uni_all, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("cyan*1.2") ///
	ciopts(recast(rcap) lcolor("cyan*1.2"))) ///
	(est3_new_ten_uni_intern, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("purple") ///
	ciopts(recast(rcap) lcolor("purple"))) ///
	(est3_new_ten_uni_ext, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("gold") ///
	ciopts(recast(rcap) lcolor("gold"))) ///
	, ///
	vertical levels(95) ///
	coeflabels(1.treated#2014.year="2014" 1.treated#2015.year="2015" ///
	1.treated#2016.year="2016" 1.treated#2018.year="2018" 1.treated#2017.year="2017" 1.treated#2019.year="2019" ///
	1.treated#2020.year="2020") ///
	xline(5 6 7, lwidth(1.5cm) lpattern(solid) lcolor(gs15)) ///
	yline(0) ///
	title("",size(medsmall))  ///
	legend(rows(2) pos(6) ring(1) ///
	label(2 "# of new tenured positions") label(4 "# of new tenured internal") label(6 "# of new tenured external"))		

graph save "${temp_path}/gr3.gph",replace 

	
coefplot ///
	(est3_new_endogamia	, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("dkgreen") ///
	ciopts(recast(rcap) lcolor("dkgreen"))) ///
	(est3_new_power, ///
	keep(1.treated#*.year)  ///
	omitted baselevels ///
	msymbol(d) mcolor("lavender") ///
	ciopts(recast(rcap) lcolor("lavender"))) ///
	, ///
	vertical levels(95) ///
	coeflabels(1.treated#2014.year="2014" 1.treated#2015.year="2015" ///
	1.treated#2016.year="2016" 1.treated#2018.year="2018" 1.treated#2017.year="2017" 1.treated#2019.year="2019" ///
	1.treated#2020.year="2020") ///
	xline(5 6 7, lwidth(1.5cm) lpattern(solid) lcolor(gs15)) ///
	yline(0) ///
	title("",size(medsmall))  ///
	legend(rows(1) pos(6) ring(1) ///
	label(2 "# of internal promotions") label(4 "# of internal promotions to full prof"))
	
graph save "${temp_path}/gr4.gph",replace 

