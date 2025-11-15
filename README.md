# Beyond the Badge of Honour: The Effect of the Italian (Department of) Excellence Initiative on Staff Recruitment
Replication package for the analysis in the paper:

> Rizzo, U., Rentocchini, F., Seeber, M. and Ramaciotti, L. (2025), Beyond the Badge of Honour: The Effect of the Italian (Department of) Excellence Initiative on Staff Recruitment, _Oxford Economic Papers_, forthcoming

Please cite the above paper when using any of these programs.

Authors: [Ugo Rizzo](https://docente.unife.it/docenti-en/ugo.rizzo?set_language=en), [Francesco Rentocchini](https://frarent.github.io/), [Marco Seeber](https://www.uia.no/english/about-uia/employees/marcos/index.html), [Laura Ramaciotti](https://docente.unife.it/docenti-en/laura.ramaciotti?set_language=en)

## Data 

### Data availability  
This study draws on publicly available data from multiple sources. Researchers wishing to replicate the analysis should download and process the data in accordance with the instructions provided below. The authors are available to provide support for reasonable replication efforts related to the data download and cleaning procedures for a period of two years following publication.

### Datasets  
| Datasets                   | Description                                                                                     | Public? | Source                                                                                                                                                                                                                                                                                                      | Notes                                                                                                                                                                                                                                                                |
|-----------------------------|-------------------------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Departments of excellence   | Names and characteristics of competing and awarded departments                                  | Yes      | Paper source accessed on March 2023 and now not accessible: [MIUR – Dipartimenti di Eccellenza](https://www.miur.gov.it/dipartimenti-di-eccellenza) | A new website provides the data as of November 2025: [DoE](https://www.mur.gov.it/it/aree-tematiche/universita/programmazione-e-finanziamenti/dipartimenti-di-eccellenza/DdE2018-2022).                                                                                                                           |
| Department staff            | Information on individuals affiliated to each university department                             | Yes      | [Cerca Università – CINECA](https://cercauniversita.cineca.it)                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                      |
| University (research) income | Amount of funding received by universities from the quota allocated based on research performance | Yes      | [MUR – Finanziamenti Università](https://www.mur.gov.it/it/aree-tematiche/universita/programmazione-e-finanziamenti/finanziamenti)                                                                                                                                                                          | For each year of data we downloaded the relative *decreto ministeriale* reporting resources allocation from the Ministry of University and Research website.                                                                                                                        |
| Province-level data         | Information on per capita value added and the unemployment rate                                 | Yes      | [ISTAT – Data Browser](https://esploradati.istat.it/databrowser/#/en)                                                                                                                                                                                                                                       |                                                                                                                                                                                                                                                                      |

### Data cleaning  
We started from a list of 352 departments. We excluded a total of 62 departments for the following reasons:  
  - The department belongs to a special school (*Sant’Anna Pisa, IUSS Pavia, IMT Lucca*), where the available information did not permit the retrieval of personnel numbers for individual departments.  
  - The department spans across multiple universities, making it impossible to determine precise personnel figures for each university.  
  - The department was created after 2013.  
  - The department experienced significant personnel transfers—either incoming or outgoing—with a transfer rate exceeding 20% of the department’s size in a single year, which signals a merger or split.  
  - University-level data were unavailable.  

Our final dataset is a balanced panel comprising 290 departments, observed from 2013 to 2020. 

The final dataset, named `data/data_for_analysis/data_for_analysis.dta`, serves as the starting point for replicating the analyses and tables presented below.



## Code for Analysis and Tables/Figures

## Code

Code for analysis and table generation is provided as part of the replication package.

The table below describes all `.do` files included in this repository, in the order they should be run.

| Name of file | Type | Description | Tables / Figures generated |
|---|---|---|---|
| `00_main.do` | main / setup | Sets Stata version, defines globals/paths, checks or installs required user-written packages (if requested), creates output/log folders, and calls all other scripts in sequence. | orchestrates full run |
| `01_descriptives_table_1.do` | analysis - descriptives | Builds the analysis sample and produces summary statistics. | **Table 1** (Descriptive statistics) |
| `02_estimates_tables_2to5.do` | analysis - main results | Estimates baseline specifications (e.g., DID and DDD with covariates) and formats outputs. | **Tables 2–5** (Main regressions) |
| `03_group_eff_table_6.do` | analysis - heterogeneity | Computes group/contrast effects and other heterogeneity analyses; exports formatted output. | **Table 6** (Group effects) |
| `04_rob_check_pt_tables_7to8.do` | analysis - robustness | Runs robustness checks (conditional and unconditional parallel trend). | **Tables 7–8** (Robustness PT) |
| `05_sdid_table_9_fig_1.do` | analysis - synthetic DID | Implements synthetic DiD; exports a figure and a final table. | **Table 9**; **Figure 1** |


### Replication Instructions

1. **Download/clone/unzip** this repository/file.
2. **Open the Stata Project file** `dpt_of_excellence.stpr`. This will allow you to view all scripts in the Project Manager.
3. **Run the main script** from Stata: `00_main.do`

This will set up the environment and execute all other scripts to reproduce the complete set of tables and figures.

#### Computational Requirements and Dependencies

- There is no need to download the user-written packages, as they are already included in `stata_packages`. Running `scripts/00_main.do` is sufficient to generate the estimates. Since several of these user-written packages have been developed recently, it is advisable to check for updates by changing `global downloads 0` to `global downloads 1` in `scripts/00_main.do`. This will automatically update all packages.
- The package was run on two different instances: 1) Stata MP version 19.5, Windows 11 Enterprise 64-bit, PC (64-bit x86-64) with 8 processors, AMD EPYC 7502 32-Core Processor (2.50 GHz), RAM 32 GB and completed in 6 hours and 16 minutes; 2) Stata SE version 19.5, Windows 11 Pro, PC (x64) with 12th Gen Intel(R) Core(TM) i7-1270P processor (2.20 GHz), RAM 32 GB, and completed in 1 hour and 37 minutes. No specific hardware or software requirements are needed, although older versions of Stata and less powerful PCs may encounter issues when running the full code.

### Directory Structure

| Directory | Content |
|---|---|
| `scripts/` | All Stata `.do` files. This folder opens automatically when you load the Stata Project `dpt_of_excellence.stpr`. |
| `data/` | Initial dataset(s) required to run the analysis. |
| `output/` | All output produced by the replication run: formatted tables and figures. |
| `stata_packages/` | Frozen copies of all user-written Stata packages needed to replicate the analysis. |
| `logs/` | Log of the most recent replication run; a new run-specific log is added for each launch. |
| `temp/` | Temporary files created during execution; these are cleaned up automatically at the end of the run. |

### Variable Codebook
The full variable codebook with variable name, label, storage type and their corresponding values and value labels is available [here](data/raw_data/)

## Acknowledgments
We are grateful to the Editor and the two anonymous referees for constructive comments on the original paper.

Francesco Rentocchini is an employee of the European Commission. The views expressed here are purely his personal views and may not in any circumstances be regarded as stating an official position of the European Commission.

**Joint responsibility**. All of the authors take full joint responsibility for any omissions or errors in this replication repository.

The `00_main.do` file builds on that provided by [Pietro Santoleri](https://pietrosantoleri.github.io/). We are indebted to Pietro for sharing the initial version with us. We have made some modifications to suit our needs and, where possible, to improve upon the already strong starting point. All errors and omissions are our own.

## License
![CC-BY-NC](data/raw_data/cc-by-nc.png) The repository is under a CC-BY-NC license. Usage by commercial entities is allowed, but reselling it is not.
