"""Module containing global settings
that affect Snakemake's runtime behavior,
in particular how software deployment works.
All settings in this module are shorthands
for Snakemake command line / profile options
except for:

    RUN_IN_DEV_MODE
        see description below for details
"""

VERBOSE = None
DRYRUN = None
USE_CONDA = None
USE_SINGULARITY = None
USE_APPTAINER = None
USE_CONTAINER = None
USE_ENV_MODULES = None

RUN_IN_DEV_MODE = None


if SNAKEMAKE_LEGACY_RUN:
    # in legacy Snakemake versions,
    # direct access to all these attributes
    # via the workflow object from global namespace
    VERBOSE = workflow.verbose
    USE_CONDA = workflow.use_conda
    USE_SINGULARITY = workflow.use_singularity
    USE_APPTAINER = USE_SINGULARITY
    USE_CONTAINER = USE_APPTAINER
    USE_ENV_MODULES = workflow.use_env_modules

else:
    # simple access to the active workflow
    # via the respective object from the global
    # namespace
    VERBOSE = workflow.output_settings.verbose
    _deployment_method_conda = api.DeploymentMethod["CONDA"]
    _deployment_method_apptainer = api.DeploymentMethod["APPTAINER"]
    _deployment_method_env_modules = api.DeploymentMethod["ENV_MODULES"]
    USE_CONDA = _deployment_method_conda in workflow.deployment_settings.deployment_method
    USE_SINGULARITY = _deployment_method_apptainer in workflow.deployment_settings.deployment_method
    USE_APPTAINER = USE_SINGULARITY
    USE_CONTAINER = USE_APPTAINER
    USE_ENV_MODULES = _deployment_method_env_modules in workflow.deployment_settings.deployment_method

assert isinstance(VERBOSE, bool)
assert isinstance(USE_CONDA, bool)
assert isinstance(USE_SINGULARITY, bool)
assert isinstance(USE_APPTAINER, bool)
assert isinstance(USE_ENV_MODULES, bool)

# special case: the --dry-run option is not accessible
# as, e.g., an attribute of the workflow object and has
# to be extracted later (see 90_staging.smk)
assert DRYRUN is None


# Special case: only constant set via the command line
# that is not a Snakemake CLI parameter, but has been
# introduced with this workflow template.
# === Why do we need this?
# If a workflow is executed in development mode, we
# can safely ignore, e.g., that some of the default
# output directories are missing; also applies to
# running tests via the 'snaketests.smk' file
RUN_IN_DEV_MODE = config.get(
    OPTIONS.devmode.name, OPTIONS.devmode.default
)
assert isinstance(RUN_IN_DEV_MODE, bool)
