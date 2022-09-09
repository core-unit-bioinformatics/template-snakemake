import pathlib

CPU_LOW = config.get("cpu_low", 2)
assert isinstance(CPU_LOW, int)
CPU_MEDIUM = config.get("cpu_medium", 4)
CPU_MED = CPU_MEDIUM
assert isinstance(CPU_MEDIUM, int)
CPU_HIGH = config.get("cpu_high", 6)
assert isinstance(CPU_HIGH, int)
CPU_MAX = config.get("cpu_max", 8)
assert isinstance(CPU_MAX, int)

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

# determine if the workflow is executed (usually locally)
# for development purposes
RUN_IN_DEV_MODE = config.get("devmode", False)
assert isinstance(RUN_IN_DEV_MODE, bool)

# if the workflow is executed in development mode,
# the paths underneath the working directory
# may not exist and that is ok
WD_PATHS_MUST_RESOLVE = not RUN_IN_DEV_MODE

WD_ABSPATH_PROCESSING = pathlib.Path("proc").resolve(strict=WD_PATHS_MUST_RESOLVE)
WD_RELPATH_PROCESSING = WD_ABSPATH_PROCESSING.relative_to(DIR_WORKING)
DIR_PROC = WD_RELPATH_PROCESSING

WD_ABSPATH_RESULTS = pathlib.Path("results").resolve(strict=WD_PATHS_MUST_RESOLVE)
WD_RELPATH_RESULTS = WD_ABSPATH_RESULTS.relative_to(DIR_WORKING)
DIR_RES = WD_RELPATH_RESULTS

WD_ABSPATH_LOG = pathlib.Path("log").resolve(strict=WD_PATHS_MUST_RESOLVE)
WD_RELPATH_LOG = WD_ABSPATH_LOG.relative_to(DIR_WORKING)
DIR_LOG = WD_RELPATH_LOG

WD_ABSPATH_RSRC = pathlib.Path("rsrc").resolve(strict=WD_PATHS_MUST_RESOLVE)
WD_RELPATH_RSRC = WD_ABSPATH_RSRC.relative_to(DIR_WORKING)
DIR_RSRC = WD_RELPATH_RSRC

WD_ABSPATH_CLUSTERLOG_OUT = pathlib.Path("log", "cluster_jobs", "out").resolve(
    strict=WD_PATHS_MUST_RESOLVE
)
WD_RELPATH_CLUSTERLOG_OUT = WD_ABSPATH_CLUSTERLOG_OUT.relative_to(DIR_WORKING)
DIR_CLUSTERLOG_OUT = WD_RELPATH_CLUSTERLOG_OUT

WD_ABSPATH_CLUSTERLOG_ERR = pathlib.Path("log", "cluster_jobs", "err").resolve(
    strict=WD_PATHS_MUST_RESOLVE
)
WD_RELPATH_CLUSTERLOG_ERR = WD_ABSPATH_CLUSTERLOG_ERR.relative_to(DIR_WORKING)
DIR_CLUSTERLOG_ERR = WD_RELPATH_CLUSTERLOG_ERR

WD_ABSPATH_GLOBAL_REF = pathlib.Path("global_ref").resolve(strict=WD_PATHS_MUST_RESOLVE)
WD_RELPATH_GLOBAL_REF = WD_ABSPATH_GLOBAL_REF.relative_to(DIR_WORKING)
DIR_GLOBAL_REF = WD_RELPATH_GLOBAL_REF

WD_ABSPATH_LOCAL_REF = pathlib.Path("local_ref").resolve(strict=WD_PATHS_MUST_RESOLVE)
WD_RELPATH_LOCAL_REF = WD_ABSPATH_LOCAL_REF.relative_to(DIR_WORKING)
DIR_LOCAL_REF = WD_RELPATH_LOCAL_REF

# fix name of run config dump file and location
RUN_CONFIG_RELPATH = DIR_RES / pathlib.Path("run_config.yaml")
RUN_CONFIG_ABSPATH = DIR_WORKING / RUN_CONFIG_RELPATH

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
