# whiskUtils
set of functions for whisk analysis to extract and analyzed data obtained by either [whisk](https://github.com/nclack/whisk) or DLC analysis (to be added later)

## wiskMatlabUtils Folder for Whisk output
_contains set of function for batch analysis based on initial functions see [whisk](https://github.com/nclack/whisk) for details_

* `freq_Phase_amp_newBatch.m`: is a batch script that is derived from `freq_Phase_amp_new.m`. The batch script is realtively hard coded in terms of folder structure and adjustment might need to be made for splicing the folder structure when run on different folders.
* `getMeasurement.m`: is a function derived from `freq_Phase_amp_new.m` with important additional steps to regularize the time series dealing with duplicate (when a frame has multiple whikser detected by the whisk software) and missing values (when the principal whisker is not detected by the whisk software) 
* `getPeaks.m`: parameters for peak detection of various whikser kinematics properties derived from `freq_Phase_amp_new.m` and with a new csv output 

## pythonUtils
_contains set of functions for downstream analysis and data visualization (TO BE ADDED)_