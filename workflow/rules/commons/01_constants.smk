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


if not pathlib.Path(config['reference_container_folder']).is_dir():
    err_msg = f"\n!!! USER ACTION REQUIRED !!!\n"
    err_msg += f"Please provide a config file with the following information:\n"
    err_msg += f"reference_container_folder: <path to folder>\n"
    err_msg += f"reference_container_names: <list of container names to use>\n\n"
    raise ValueError(err_msg)
else:
    DIR_REFCON = pathlib.Path(config['reference_container_folder']).resolve(strict=True)
