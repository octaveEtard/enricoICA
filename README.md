# enricoICA
pre-processing & ICA code for Enrico. Requires the `MEEGtools` [package](https://github.com/octaveEtard/MEEGtools).

Work in progress, but basic core functions are working.

## Installation
This is a [Matlab package](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html): add folder `functions` to your path, and preface function names with `enICA.` to access them.
Edit `enICA.getPath` to specify data location.

## Pipeline
Run `run_preprocessing` first for filtering + downsampling + ASR + interpolation + average reference.
    -> This will save new processed EEG files.
Then run `run_ICA` to run ICA + classification(ICLabel) + rejection of ICs
    -> This will save new EEG files with ICs removed.
All processing steps are saved in EEG.comments + written to standalone `.log` files.

## TODO:
- add % bad data as identified by ASR
- add saving of ICA weights to standalone file
- add option to run preprocessing in parallel (already in for ICA)
- clean-up AMICA code
