use "${data_path}/db_robcheck.dta",clear

include "${script_path}/RC01_bad_controls.do"

include "${script_path}/RC02_poisFE.do"

include "${script_path}/RC03_restricted_sample.do"

include "${script_path}/RC04_thresholds.do"

*include "${script_path}/RC05_dynamic_effects.do"

include "${script_path}/RC07_PT.do"

