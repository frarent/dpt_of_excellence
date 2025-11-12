*=============================================================================*
* Project title: Beyond the Badge of Honour: The Effect of the Italian 
*	(Department of) Excellence Initiative on Staff Recruitment 
* Created by: Francesco Rentocchini and Ugo Rizzo
* Last Update: 11/3/2025
*=============================================================================*

// Acknowledgments
*=============================================================================*
/* 
This master file builds on that provided by Pietro Santoleri (https://pietrosantoleri.github.io/)
We are indebted to Pietro for sharing the initial version with us. 
We have made some modifications to suit our needs and, where possible, to improve upon the already strong starting point. 
Pietro - Cotton misses you very much. 
All errors and omissions are our own.
*/ 

// Clear Memory
*=============================================================================*
clear all

// Set options 
*=============================================================================*

// Download raw data (0 for no; 1 for yes)
global downloads 0

// Run main analysis script (0 for no; 1 for yes)
global analysis 1

// Run rob check script (0 for no; 1 for yes)
global robcheck 1 

// Run rob check script long (0 for no; 1 for yes)
global robcheck_long 0



// Use included packages
*=============================================================================*
cap mkdir "stata_packages"

cap adopath - PERSONAL
cap adopath - PLUS
cap adopath - SITE
cap adopath - OLDPLACE
adopath + "stata_packages"
net set ado "stata_packages"


// Download packages 
local packages  blindschemes /// plot scheme 
	reghdfe ftools /// high dimensional fixed effects regressions
	estout /// table exporting tool
	distinct /// num unique observations
	coefplot // plots of coefficients
	
if $downloads == 1 {
	foreach name of local packages  {
		ssc install `name',replace 	// Install  Packages
		

	}

	net install sdid, /// synthetic DID
		from("https://raw.githubusercontent.com/daniel-pailanir/sdid/master") replace
	net install http://www.stata.com/users/vwiggins/grc1leg.pkg // combine graphs

}


// Create file paths 
*=============================================================================*
* data
cap mkdir "data"
cap mkdir "data/data_for_analysis"
cap mkdir "data/raw_data" 

* directory for temporary files
cap mkdir "temp"

* directory for results
cap mkdir "output"

* directory for logs
cap mkdir "logs"


// Set your file paths, These are relative to where the project file is saved. 
*=============================================================================*

global data_path "data/data_for_analysis"
global raw_data_path "data/raw_data" 
global temp_path "temp" 

global script_path "scripts" 

global output "output" 
global log_path "logs" 



// Initialize log and record system parameters
cap log close
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$log_path/`datetime'.log.txt"
log using "`logfile'", text

di "Begin date and time: $S_DATE $S_TIME"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"

// Set Date
global date = subinstr("$S_DATE", " ", "-", .)

// Version of stata
version 18

// Specify Screen Width for log files
set linesize 255

// Set Graph Scheme
graph set window fontface default
set scheme plotplainblind

// Set table format
global tab_fmt html

// Allow the screen to move without having to click more
set more off

// Drop everything in mata
matrix drop _all

// Run do files
*=============================================================================*

// Run main analysis
if $analysis == 1 {
	include $script_path/01_descriptives_table_1.do
	include $script_path/02_estimates_tables_2to5.do
	include $script_path/03_group_eff_table_6.do
}

// Run robustness checks
if $robcheck == 1 {
	include $script_path/04_rob_check_pt_tables_7to8.do
}

// Run robustness checks (time consuming one)
if $robcheck_long == 1 {
	include $script_path/05_sdid_table_9_fig_1.do
}


* End log
di "End date and time: $S_DATE $S_TIME"
log close

// Housekeeping (clean all temporary files)
*==========================================================================*
local temp: dir ${temp_path} files "*"
dis `temp'

foreach file of local temp {
	erase "${temp_path}/`file'"
}

