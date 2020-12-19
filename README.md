# Data & Analysis Code
Aberrant Sensory Encoding in Patients with Autism  
Jean-Paul Noel*, Ling-Qi Zhang*, Alan A. Stocker, and Dora E. Angelaki  
https://www.biorxiv.org/content/10.1101/2020.03.04.976191v1  

## Dependencies
- MATLAB cbrewer: https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab  
- MATLAB circular statistics toolbox: https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics  
- We have already included them here (`cbrewer`) and (`CircStat`), but would like to explicitly acknowledge the use of  these two packages.

## Data
- All the `.mat` files in the root directory are data for the combined subject across conditions; Data for each indivudal subject can be found in `./woFB` (without feedback), `./wFB1` (with feedback 1), and `./wFB2` (with feedback 2).

## Code Usage
- Set the root directory of the project as the current directory of MATLAB.
- Each folder contains one matlab script (and other helper function files) that produce the corresponding figure in the paper (Fig. 2-5, Fig. S1, S2-3).
- Run the "addpath" section first with the "Run Section" function in MATLAB (to include helper functions in the path), and then run the entire script.
- Please address any questions you have to lingqiz@sas.upenn.edu.
