# enricoICA
pre-processing & ICA code for Enrico. Requires the `MEEGtools` [package](https://github.com/octaveEtard/MEEGtools).

Work in progress, but basic core functions are working.

## Installation
This is a [Matlab package](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html): add folder `functions` to your path, and preface function names with `enICA.` to access them.
Edit `enICA.getPath` to specify data location.

## Pipeline
1 - Run `run_preprocessing` first for filtering + downsampling + ASR + interpolation + average reference.
    -> This will save new processed EEG files.
2 - Then run `run_ICA` to run ICA + classification(ICLabel)
    -> This will save new EEG files with ICA information removed.
3 - Then run `run_reject_ICs` to reject ICs
    -> This will use the ICA info stored in the EEG files and decision thresholds to reject ICs, and save new EEG files with IC removed.

In step 2 make sure `opt.rejectIC.do` is set to `false`, otherwise IC rejection will be run. Separating step 2 & 3 enables experimenting with different IC rejection strategies without having to rerun ICA each time. Do set `opt.rejectIC.do` to `true` if the former is the intended behaviour.
    
All processing steps are saved in EEG.comments + written to standalone `.log` files.

## TODO:
- add option to run preprocessing in parallel (already in for ICA)
- clean-up AMICA code
