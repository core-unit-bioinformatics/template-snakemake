# Template for developing Snakemake workflows

Brief description of workflow

## Required software environment

Standardized workflows are designed with minimal assumptions about the local software environment.

In essence, the following should suffice to get started:
1. Linux OS: Debian, Ubuntu, CentOS, Rocky and related distributions should be fine
2. Python3: modern is likely better (3.8 or 3.9)
3. Conda (or mamba): for automatic setup of all software dependencies
    - Note that you can run the workflow w/o Conda, but then all tools listed under `workflow/envs/*.yaml` [not `dev_env.yaml`] need to be in your `$PATH`.

Internal (template) remark: adapt the above if the workflow deployment has additional requirements (e.g., Singularity).

## Required input data

Add info here

## Produced output data

Add info here

# Deploying the workflow on execution hardware

1. run `./init.py` (requires Python3)
    - this will create an "execution" Conda environment,
    and a Snakemake working directory plus standard subfolders
    one level above the repository location
2. activate the created Conda environment: `cd .. && conda activate ./exec_env`
3. prepare profile and configuration files as necessary, and run Snakemake


# Developing the workflow locally

1. run `./init.py --dev-only` (requires Python3)
    - this will skip creating the workflow working directory and subfolders
2. activate the created Conda environment: `conda activate ./dev_env`
3. write your code
4. run the recommended code checks with the following tools:
    - Python scripts:
        - linting: `pylint <script.py>`
        - organize imports: `isort <script.py>`
        - code formatting: `black [--check] .`
    - Snakemake files:
        - linting: `snakemake --lint`
        - code formatting: `snakefmt [--check] .`
5. after checking and standardizing your code, commit your changes:

# Citation

If you use this workflow (or non-trivial parts of it such as a whole sub-module),
please credit the Core Unit Bioinformatics as follows:

1. you use a release version with DOI:
    - please use the DOI to link to the workflow version
    - integrate the DOI into the references of your publication (if applicable)
2. you use a dev/non-release version:
    - please link to the workflow repository where appropriate (e.g., in your Methods section)
    - (recommended: report the exact commit hash you are referring to)
    - please add the following statement to your acknowledgements:
    ```
    This work was supported by the Core Unit Bioinformatics of the Medical Faculty
    of the Heinrich Heine University Düsseldorf.
    ```
3. you think none of the above options apply in your case:
    - please get in touch and let's talk about it :-)
