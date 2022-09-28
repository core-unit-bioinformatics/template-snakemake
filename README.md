# Template for developing Snakemake workflows

Brief description of workflow

## Required software environment

Standardized workflows are designed with minimal assumptions about the local software environment.

In essence, the following should suffice to get started:
1. Linux OS: Debian, Ubuntu, CentOS, Rocky and related distributions should be fine
2. Python3: modern is likely better (3.8 or 3.9)
3. Conda (or mamba): for automatic setup of all software dependencies
    - Note that you can run the workflow w/o Conda, but then all tools listed under `workflow/envs/*.yaml` [not `dev_env.yaml`] need to be in your `$PATH`.

For a detailed setup guide, please refer to [the workflow documentation](docs/README.md).

**Internal (template) remark**: adapt the above if the workflow deployment has additional requirements (e.g., Singularity).

## Required input data

Add info here - be concise, and provide more details in [the workflow documentation](docs/README.md).

## Produced output data

Add info here - be concise, and provide more details in [the workflow documentation](docs/README.md).

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
