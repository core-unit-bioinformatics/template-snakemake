import pathlib

# stored if needed for logging purposes
VERBOSE = workflow.verbose
assert isinstance(VERBOSE, bool)

USE_CONDA = workflow.use_conda
assert isinstance(USE_CONDA, bool)

USE_SINGULARITY = workflow.use_singularity
assert isinstance(USE_SINGULARITY, bool)

USE_ENV_MODULES = workflow.use_env_modules
assert isinstance(USE_ENV_MODULES, bool)

ENV_MODULE_SINGULARITY = config.get("env_module_singularity", "Singularity")

DIR_SNAKEFILE = pathlib.Path(workflow.basedir).resolve(strict=True)
PATH_SNAKEFILE = pathlib.Path(workflow.main_snakefile).resolve(strict=True)
assert DIR_SNAKEFILE.samefile(PATH_SNAKEFILE.parent)

# in principle, a workflow does not have to make use of scripts,
# and thus, the path underneath workflow may not exist
DIR_SCRIPTS = DIR_SNAKEFILE.joinpath("scripts").resolve(strict=False)
DIR_ENVS = DIR_SNAKEFILE.joinpath("envs").resolve(strict=True)

DIR_REPOSITORY = DIR_SNAKEFILE.parent
DIR_REPO = DIR_REPOSITORY

DIR_WORKING = pathlib.Path(workflow.workdir_init).resolve(strict=True)
WORKDIR = DIR_WORKING

# specific constants for the use of reference containers
# as part of the pipeline
USE_REFERENCE_CONTAINER = config.get("use_reference_container", False)
assert isinstance(USE_REFERENCE_CONTAINER, bool)
USE_REFCON = USE_REFERENCE_CONTAINER

if USE_REFERENCE_CONTAINER:
    try:
        DIR_REFERENCE_CONTAINER = config["reference_container_store"]
    except KeyError:
        raise KeyError(
            "The config option 'use_reference_container' is set to True. "
            "Consequently, the option 'reference_container_store' must be "
            "set to an existing folder on the file system containing the "
            "reference container images (*.sif files)."
        )
    else:
        DIR_REFERENCE_CONTAINER = pathlib.Path(DIR_REFERENCE_CONTAINER).resolve(
            strict=True
        )
else:
    DIR_REFERENCE_CONTAINER = pathlib.Path("/")
DIR_REFCON = DIR_REFERENCE_CONTAINER
