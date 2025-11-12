# Beyond the Badge of Honour: The Effect of the Italian (Department of) Excellence Initiative on Staff Recruitment
Replication package for the analysis in the paper:

> Rizzo, U., Rentocchini, F., Seeber, M. and Ramaciotti, L. (2025), Beyond the Badge of Honour: The Effect of the Italian (Department of) Excellence Initiative on Staff Recruitment, _Oxford Economic Papers_, forthcoming

Please cite the above paper when using any of these programs.

Authors: [Ugo Rizzo](https://docente.unife.it/docenti-en/ugo.rizzo?set_language=en), [Francesco Rentocchini](https://frarent.github.io/), [Marco Seeber](https://www.uia.no/english/about-uia/employees/marcos/index.html), [Laura Ramaciotti](https://docente.unife.it/docenti-en/laura.ramaciotti?set_language=en)

## Acknowledgments
We are grateful to the Editor and the two anonymous referees for constructive comments on the original paper.

Francesco Rentocchini is an employee of the European Commission. The views expressed here are purely his personal views and may not in any circumstances be regarded as stating an official position of the European Commission.

**Joint responsibility**. All of the authors take full joint responsibility for any omissions or errors in this replication repository.

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
  - University-level data were unavailable (specifically, the Ministry does not provide information on the public income of the University of Trento).  

Our final dataset is a balanced panel comprising 290 departments, observed from 2013 to 2020. 

The final dataset, named `xxx.dta`, serves as the starting point for replicating the analyses and tables presented below.



## Code for Analysis and Tables/Figures

Code for analysis and table generation is provided as part of the replication package. 

In the table below, a description of all the do files and folders in the replication package is provided. Files are organised in the order in which they should be run.


XXX

### Replication Instructions
Download the entire zipped folder and open the Stata project `XXX.stpr`. All the scripts will appear in the project manager:

- `scripts/00.main.do`: sets up the environment and calls the other scripts to run the estimates and create tables and graphs. 

- `scripts/01.XXX.do`: contains XXX.

#### Computational Requirements
- Software requirements: Stata MP (the code was last run with version 19.5).
- There is no need to download the user-written packages as they are already contained in `stata_packages`. It suffices to run `scripts/00_main.do` to get the estimates. As several of these user-written packages have been developed recently, it is worth checking for updates by changing `global downloads 0` into `global downloads 1` in `scripts/00_main.do`. This will automatically update all packages.
- The package was run on: 1) OS, CPU, memory and disk space 
- The wall-clock time given the provided computer hardware, expressed in appropriate units (minutes, days).


### Variable Codebook

## License
![CC-BY-NC](data/raw_data/cc-by-nc.png) The README is under a CC-BY-NC license. Usage by commercial entities is allowed, but reselling it is not.
