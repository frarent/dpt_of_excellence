*=============================================================================*
* Project title: The effect of DoE on university department hiring
* Created by: Francesco Rentocchini and Ugo Rizzo
* Original Date: 21/03/2024
* Last Update: 11/3/2025
*=============================================================================*

// Clear Memory
*=============================================================================*
clear all

// Set options 
*=============================================================================*

// Download raw data (0 for no; 1 for yes)
global downloads 0

// Build dataset used in analysis (0 for no; 1 for yes)
global build_data 0

// Run main analysis script (0 for no; 1 for yes)
global analysis 0

// Run rob check script (0 for no; 1 for yes)
global robcheck 0 

// Run partial effects (0 for no; 1 for yes)
global partial 0

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
local packages estout cleanplots coefplot psweight reghdfe ftools ppmlhdfe  ///
	drdid blindschemes
if $downloads == 1 {
	foreach name of local packages  {
		ssc install `name',replace 	// Install  Packages
	}
	net install http://www.stata.com/users/vwiggins/grc1leg.pkg
	net install sdid, ///
		from("https://raw.githubusercontent.com/daniel-pailanir/sdid/master") replace
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

* directory for auxiliary scripts
cap mkdir "scripts/auxiliary"


// Set your file paths, These are relative to where the project file is saved. 
*=============================================================================*

global data_path "data/data_for_analysis"
global raw_data_path "data/raw_data" 
global temp_path "temp" 

global script_path "scripts" 
global aux_path "scripts/auxiliary" 

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

// Build data
if $build_data == 1 {
	do $script_path/07_build_DBs.do
}

// Run main analysis
if $analysis == 1 {
	do $script_path/08_analysis_avg.do
}

// Run robustness checks
if $robcheck == 1 {
	do $script_path/09_analysis_avg_RC.do
}

// Run robustness checks
if $partial == 1 {
	do $script_path/11_partial_effects.do
}

// Run robustness checks (time consuming one)
if $robcheck_long == 1 {
	do $script_path/10_analysis_avg_RC_long.do
}


* End log
di "End date and time: $S_DATE $S_TIME"
log close

// Housekeeping
*==========================================================================*
local temp: dir ${temp_path} files "*"
dis `temp'

foreach file of local temp {
	erase "${temp_path}/`file'"
}

