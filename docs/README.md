# Documentation for Snakemake workflow NAME HERE

Describe the purpose of the workflow (the big picture)

## General concepts

### Folder structure

By following the below guides, you will end up with a Snakemake
working directory (for short: `wd`) with the following subfolders:

`wd/results/`: this folder contains final results and some workflow metadata
and represents the only relevant output folder from the end user perspective.
Accidentally deleting this folder after a successful pipeline run means you have to
restart the pipeline and Snakemake will check which result files have to be recreated.

`wd/proc/`: the `processing` folder contains intermediate files
and is not of interest to end users. As a design principle, deleting this
folder after successful pipeline execution must not result in the loss of
any relevant data.

The folders `wd/log/` (log files), `wd/rsrc/` (resource/benchmark files) and both
reference data folders (`wd/global_ref/` and `wd/local_ref/`) should not contain
any processed sample data (clean design), and are only relevant for workflow developers.

### Accounting: the file manifest

If properly set up, each workflow automatically creates a result file
named `manifest.tsv` (in the folder `wd/results/`). This
file lists all (i) input, (ii) reference (from `wd/global_ref/`) and (iii)
result files together with metadata such as file size and data checksums
(both MD5 and SHA256). This file is of utmost importance to track which
input files in conjunction with which reference files were used to produce
a certain set of result files. Never-ever delete this file.

**Important** Preparing the computation of all checksums etc. that are needed
to complete the file manifest, is done during a `--dryrun` of the pipeline. If you
are sure that the pipeline will run start to finish, run Snakemake with the
option `--dryrun` twice before actually starting the computations. This will
ensure that all metadata files (checksums etc.) will be known to Snakemake
when the pipeline run starts and will be created as part of the regular flow
of computations.

### Rerunning the exact same workflow

By default, after a successful pipeline run, a complete dump of the workflow
configuration is written to a file named `run_config.yaml` (in the folder
`wd/results/`). This configuration dump includes the information which user
executated the workflow and which (code) version of the worklow was used.
Assuming that the execution infrastructure (i.e., the compute cluster) is
the same, it is possible to use just this configuration file to rerun the workflow
in the exact same way. Never-ever delete this file.

## Documentation for users

If you want to use this workflow as a black box to process your data,
simply follow the below series of steps to get things up and running.

### Deploying the workflow on execution hardware

1. run `./init.py` (requires Python3)
    - this will create an "execution" Conda environment,
    and a Snakemake working directory plus standard subfolders
    one level above the repository location
2. activate the created Conda environment: `cd .. && conda activate ./exec_env`
3. prepare profile and configuration files as necessary, and run Snakemake


### Detailed output specification

For detailed descriptions, this should be moved in a separate markdown file.

## Documentation for developers

### Developing the workflow locally

1. run `./init.py --dev-only` (requires Python3)
    - this will skip creating the workflow working directory and subfolders
2. activate the created Conda environment: `conda activate ./dev_env`
3. write your code, and add tests to `workflow/snaketests.smk`
4. run tests:
    - note that some tests may be expected to fail and may produce error messages
    - if Snakemake reports a successful pipeline run, then all tests have succeeded
      irrespective of log messages that look like errors
    - if you want to test the functions loading reference data from reference containers,
      you need to build the test container `test_v0.sif` and copy it into the
      working directory for the workflow test run. Refer to the
      [reference container repository](https://github.com/core-unit-bioinformatics/reference-container)
      for build instructions.

```bash
# Example: test w/o reference container
# Note: execute the workflow first in
# '--dryrun' mode to trigger (and test)
# the complete MANIFEST creation
snakemake --cores 1 \
    [--dryrun] \
    --config devmode=True \
    --directory wd/ \
    --snakefile workflow/snaketests.smk

# Example: test w/ reference container;
# the container 'test_v0.sif' must exist
# in the working directory: 'wd/test_v0.sif'
# Note: execute the workflow first in
# '--dryrun' mode to trigger (and test)
# the complete MANIFEST creation
snakemake --cores 1 \
    [--dryrun] \
    --config devmode=True \
    --directory wd/ \
    --configfiles config/testing/params_refcon.yaml \
    --snakefile workflow/snaketests.smk
```
    
5. run the recommended code checks with the following tools:
    - Python scripts:
        - linting: `pylint <script.py>`
        - organize imports: `isort <script.py>`
        - code formatting: `black [--check] .`
    - Snakemake files:
        - linting: `snakemake --config devmode=True --lint`
        - code formatting: `snakefmt [--check] .`
6. after checking and standardizing your code, commit and push your changes
