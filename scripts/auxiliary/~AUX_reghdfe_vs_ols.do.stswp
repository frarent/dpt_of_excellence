use "${data_path}/db_robcheck.dta",clear
drop post2

/*--------------------------------------------------
SET GLOBALS FOR ANALYSIS
----------------------------------------------------*/

global covar lagi dep_transfer_horizontal tot_premiale VA_percap 
global tab_fmt html 

global y new_position	new_entry	new_rtda	new_rtdb	new_ten_uni_all	new_ten_uni_intern	new_ten_uni_ext	new_endogamia new_power

global y1 est*_new_position est*_new_entry
global y2 est*_new_rtda est*_new_rtdb
global y3 est*_new_ten_uni_all	est*_new_ten_uni_intern	est*_new_ten_uni_ext
global y4 est*_new_endogamia	est*_new_power

global plot_y1 est3_new_position est3_new_entry
global plot_y2 est3_new_rtda est3_new_rtdb
global plot_y3 est3_new_ten_uni_all	est3_new_ten_uni_intern	est3_new_ten_uni_ext
global plot_y4 est3_new_endogamia	est3_new_power


/*--------------------------------------------------
PRE/POST TREATMENT
----------------------------------------------------*/
tab year

g post3=1 if year>=2018&year<=2020
replace post3=0 if year>=2013&year<=2017

g post2=1 if year>=2018&year<=2020
replace post2=0 if year>=2014&year<=2017


reghdfe new_position  i.treated##i.post2 , ///
	a(id treated) cluster(id)
	
reghdfe new_position  i.treated##i.post3  , ///
	a(id treated) cluster(id)
	

preserve
	collapse new_position treated  $covar w_ipw_pre uni_name_enc,by(id post3)

*	br id  new_position treated post2 $covar w_ipw_pre uni_name_enc


	reghdfe new_position  i.treated##i.post3 , cluster(id) a(id)
	reg new_position  i.treated##i.post3 , cluster(id)
	
restore
