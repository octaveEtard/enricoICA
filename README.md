# enricoICA
ICA code for Enrico. Requires the `MEEGtools` [package](https://github.com/octaveEtard/MEEGtools).
Preface function name with `enICA.`.
Edit `enICA.getPath` to specify default data location.

Work in progress, but basic core functions are working.

## Pipeline
Run `run_preprocessing` first for filtering + downsampling + ASR + interpolation + average reference.
Then run `run_ICA` to run ICA + classification(ICLabel)

## TODO:
- implement ICA cleaning (currently only ICA + classif; need to add rejection of IC & backprojection)
- add % bad data as identified by ASR
- add option to run preprocessing in parallel (already in for ICA)
- clean-up AMICA code
