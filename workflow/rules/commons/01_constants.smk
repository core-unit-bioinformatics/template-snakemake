import enum
import pathlib
import re
import sys


WAIT_ACC_LOCK_SECS = config.get("wait_acc_lock_secs", 60)

CPU_LOW = config.get("cpu_low", 2)
assert isinstance(CPU_LOW, int)
CPU_MEDIUM = config.get("cpu_medium", 4)
CPU_MED = CPU_MEDIUM
assert isinstance(CPU_MEDIUM, int)
CPU_HIGH = config.get("cpu_high", 6)
assert isinstance(CPU_HIGH, int)
CPU_MAX = config.get("cpu_max", 8)
assert isinstance(CPU_MAX, int)

# special case: the --dry-run option is not accessible
# as, e.g., an attribute of the workflow object and has
# to be extracted later (see 09_staging.smk)
DRYRUN = None

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
NAME_SNAKEFILE = PATH_SNAKEFILE.stem
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

# if the name of the snakefile is "snaketests" and the
# developer has not set the devmode option, print a hint
# to help diagnose path resolution errors
if NAME_SNAKEFILE == "snaketests" and not RUN_IN_DEV_MODE:
    hint_msg = "\nDEV HINT:\n"
    hint_msg += "You are executing the 'snaketests' pipeline,"
    hint_msg += " but you did not set the config option:\n"
    hint_msg += " '--config devmode=True'\n"
    hint_msg += "This may lead to FileNotFoundErrors for the"
    hint_msg += " subfolders expected to exist"
    hint_msg += " (proc/, results/ and so on) in the working directory.\n\n"
    sys.stderr.write(hint_msg)

# should the accounting files be reset?
RESET_ACCOUNTING = config.get("resetacc", False)
assert isinstance(RESET_ACCOUNTING, bool)

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

SAMPLE_SHEET_PATH = config.get("samples", "")
SAMPLE_SHEET_NAME = None

RUN_SUFFIX = config.get("suffix", "")  # means: default is no suffix
if RUN_SUFFIX == "derive" and not SAMPLE_SHEET_PATH:
    raise ValueError("No sample sheet specified, hence, cannot derive run suffix.")

if SAMPLE_SHEET_PATH:
    SAMPLE_SHEET_PATH = pathlib.Path(SAMPLE_SHEET_PATH).resolve(strict=True)
    assert SAMPLE_SHEET_PATH.name.lower().endswith(".tsv"), \
        "Only TSV tables allowed as sample sheet (*.tsv)."
    SAMPLE_SHEET_NAME = SAMPLE_SHEET_PATH.stem
    assert SAMPLE_SHEET_NAME
    if RUN_SUFFIX == "derive":
        RUN_SUFFIX = SAMPLE_SHEET_NAME
    # set path in results/ folder to keep a copy
    # of the sample sheet as part of the output
    COPY_SAMPLE_SHEET_RELPATH = DIR_RES.joinpath(f"{SAMPLE_SHEET_NAME}.tsv")
    COPY_SAMPLE_SHEET_ABSPATH = COPY_SAMPLE_SHEET_RELPATH.resolve()
else:
    # set target path of sample sheet under results/
    # to empty path if not sample sheet provided
    COPY_SAMPLE_SHEET_RELPATH = "no-sample-sheet"
    COPY_SAMPLE_SHEET_ABSPATH = ""

# Postprocess the run suffix to consist
# only of digits, chars, and "minus"
RUN_SUFFIX = RUN_SUFFIX.replace(".", "-").replace("_", "-")
RUN_SUFFIX = "".join(re.findall("[a-z0-9\-]+", RUN_SUFFIX, re.IGNORECASE))
# in case the above resulted in two or more
# consecutive hyphens, replace with single one
RUN_SUFFIX = re.sub("\-\-+", "-", RUN_SUFFIX)

if RUN_SUFFIX:
    RUN_SUFFIX = f".{RUN_SUFFIX}"

# fix name of run config dump file and location
RUN_CONFIG_RELPATH = DIR_RES.joinpath(f"run_config{RUN_SUFFIX}.yaml")
RUN_CONFIG_ABSPATH = RUN_CONFIG_RELPATH.resolve()

# fix name of manifest file and location
MANIFEST_RELPATH = DIR_RES.joinpath(f"manifest{RUN_SUFFIX}.tsv")
MANIFEST_ABSPATH = MANIFEST_RELPATH.resolve()

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


ACCOUNTING_FILES = {
    "inputs": DIR_PROC.joinpath(".accounting", "inputs.listing"),
    "references": DIR_PROC.joinpath(".accounting", "references.listing"),
    "results": DIR_PROC.joinpath(".accounting", "results.listing"),
}


class TimeUnit(enum.Enum):
    HOUR = 1
    hour = 1
    hours = 1
    hrs = 1
    h = 1
    MINUTE = 2
    minute = 2
    minutes = 2
    min = 2
    m = 2
    SECOND = 3
    second = 3
    seconds = 3
    sec = 3
    s = 3


class MemoryUnit(enum.Enum):
    BYTE = 0
    byte = 0
    bytes = 0
    b = 0
    B = 0
    KiB = 1
    kib = 1
    kb = 1
    KB = 1
    k = 1
    K = 1
    kibibyte = 1
    MiB = 2
    mib = 2
    mb = 2
    MB = 2
    m = 2
    M = 2
    mebibyte = 2
    GiB = 3
    gib = 3
    gb = 3
    GB = 3
    g = 3
    G = 3
    gibibyte = 3
    TiB = 4
    tib = 4
    tb = 4
    TB = 4
    t = 4
    T = 4
    tebibyte = 4
