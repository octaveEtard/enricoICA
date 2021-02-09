# enricoICA
pre-processing & ICA code for Enrico. Requires the `MEEGtools` [package](https://github.com/octaveEtard/MEEGtools).

Work in progress, but basic core functions are working.

## Pipeline
This is a [Matlab package](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html): add folder `functions` to your path, and preface function names with `enICA.` to access them.
Edit `enICA.getPath` to specify data location.

## Pipeline
Run `run_preprocessing` first for filtering + downsampling + ASR + interpolation + average reference.
Then run `run_ICA` to run ICA + classification(ICLabel)

## TODO:
- implement ICA cleaning (currently only ICA + classif; need to add rejection of IC & backprojection)
- add % bad data as identified by ASR
- add option to run preprocessing in parallel (already in for ICA)
- clean-up AMICA code
