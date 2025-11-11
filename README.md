# Beyond the Badge of Honour: The Effect of the Italian (Department of) Excellence Initiative on Staff Recruitment
Replication package for the paper "Beyond the Badge of Honour: The Effect of the Italian (Department of) Excellence Initiative on Staff Recruitment" published on _Oxford Economic Papers_


Download the entire zipped folder and open the Stata project `XXX.stpr`. All the scripts will appear in the project manager:

- `scripts/00.master.do`: sets up the environment and calls the other scripts to run the estimates and create tables and graphs. There is no need to adjust paths, nor downloading the user-written packages as they are already contained in `stata_packages`. It suffices to run `scripts/00_master.do` to get the estimates.

- `scripts/01.XXX.do`: contains XXX.

As several of these user-written packages have been developed recently, it is worth checking for updates by changing `global downloads 0` into `global downloads 1` in `scripts/00_master.do`. This will automatically update all packages.
