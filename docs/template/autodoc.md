# Parameter and function docs for context: TEMPLATE

## Module: commons::05_docgen.smk

**Module file**: `workflow/rules/commons/05_docgen.smk`

### Documentation level: GLOBALOBJ

1. DOCREC
    - datatype: <class 'snakemake.workflow.DocRecorder'>
    - documentation: Alias/short hand for DOC_RECORDER.
2. DOC_RECORDER
    - datatype: <class 'snakemake.workflow.DocRecorder'>
    - documentation: Instance of the `DocRecorder` class that is globally available to record documentation *in place*. The DocRecorder class has three member functions to record documentation about 'objects' (in the Python sense) in module contexts. At the beginning of each module, call the function `DOC_RECORDER.add_module_doc(...)` to start a new module context. After that, call the function `DOC_RECORDER.add_member_doc(...)` for each member (everything except functions/methods) of the module that you want to document. For functions and object methods, call `DOC_RECORDER.add_function_doc(...)`. The documentation is dumped as a Markdown file and thus supports (basic) Markdown syntax for emphasis etc. In order to generate the documentation, execute the workflow with the target rule `run_build_docs`.
3. DocContext
    - datatype: <class 'enum.EnumType'>
    - documentation: Enum listing the different documentation contexts. The context is used to sort the dumped documentation Markdown file into `docs/<context>/autodoc.md`. The currently supported contexts are: (1) TEMPLATE; (2) WORKFLOW
4. DocLevel
    - datatype: <class 'enum.EnumType'>
    - documentation: Enum listing the different documentation levels such as USERCONFIG and GLOBALVAR that need to be specified when documenting module 'members' and 'functions'. See documentation of the DOC_RECORDER object for more details. The currently supported levels are: (1) USERCONFIG; (2) GLOBALVAR; (3) GLOBALFUN; (4) GLOBALOBJ; (5) OBJMETHOD; (6) DEVONLY

### Documentation level: OBJMETHOD

1. add_function_doc
    - datatype: <class 'snakemake.workflow.DocRecorder'>.<class 'method'>
    - documentation: 
```
        This function of the DocRecorder class / DOCREC instance
        must be called to document either module-level / global
        functions or class methods. In case of class methods,
        the documentation level is set to DocLevel.OBJMETHOD and to
        DocLevel.GLOBALFUN otherwise.

        Args:
            function (callable): function/method to document
            parent (None or class): parent class if class method

        Returns:
            None
        
```
2. add_member_doc
    - datatype: <class 'snakemake.workflow.DocRecorder'>.<class 'method'>
    - documentation: 
```
        This function of the DocRecorder class / DOCREC instance
        must be called to document module-level members, i.e. global
        variables, functions, objects, user configurables and
        developer-only information.

        Args:
            doc_level (DocLevel): the documentation level
            name (str): name of the documented thing
            thing (any): the documented thing (i.e., some Python object)
            documentation (str): the documentation for thing

        Returns:
            None

        Raises:
            ValueError: if doc_level in [DocLevel.OBJMETHOD, DocLevel.GLOBALFUN]
        
```
3. add_module_doc
    - datatype: <class 'snakemake.workflow.DocRecorder'>.<class 'method'>
    - documentation: 
```
        This member function must be called at the beginning
        of each new module to record the documentation
        in the correct module file context.

        Args:
            doc_context (DocContext): documentation context enum type
            module_name (str or list of str): name of the module given as relative path

        Returns:
            None
        
```

## Module: commons::10-constants::00_legacy.smk

**Module file**: `workflow/rules/commons/10-constants/00_legacy.smk`

### Documentation level: DEVONLY

1. SNAKEMAKE_LEGACY_RUN
    - datatype: <class 'bool'>
    - documentation: This variable can be checked if it is critical to determine whether or not the workflow is executed with a Snakemake legacy version (typically v7) or with a more recent release (typically v9+).

## Module: commons::30-settings::00-infrastructure::10_software.smk

**Module file**: `workflow/rules/commons/30-settings/00-infrastructure/10_software.smk`

### Documentation level: DEVONLY

1. ENV_MODULE_APPTAINER
    - datatype: <class 'str'>
    - documentation: The name of the env(ironment) module that loads the Apptainer executable into `$PATH`. This is typically only relevant in HPC environments. Apptainer is the successor of Singularity and needed to execute containerized tools. The template uses this variable if CUBI-style reference containers are used.
2. ENV_MODULE_SINGULARITY
    - datatype: <class 'str'>
    - documentation: The name of the env(ironment) module that loads the Singularity executable into `$PATH`. This is typically only relevant in HPC environments. Note that Singularity is deprecated and has been replaced by Apptainer. The template uses this variable if CUBI-style reference containers are used.

## Module: commons::30-settings::10-runtime::00_snakemake.smk

**Module file**: `workflow/rules/commons/30-settings/10-runtime/00_snakemake.smk`

### Documentation level: GLOBALVAR

1. DEBUG
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow is executed via `snakemake --debug [...]`, which allows to set breakpoints in `run:` blocks.
2. DRYRUN
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow is executed via `snakemake --dryrun [...]`.
3. VERBOSE
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow is executed via `snakemake --verbose [...]`, i.e. Snakemake is printing verbose/debugging output.

### Documentation level: DEVONLY

1. RUN_IN_DEV_MODE
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow is executed via `snakemake --config devmode=True [...]`
2. RUN_IN_TEST_MODE
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow is executed via `snakemake [...] run_tests` or `snakemake [...] run_tests_no_manifest`.
3. USE_APPTAINER
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow uses Apptainer (Singularity) for software deployment.
4. USE_CONDA
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow uses Conda for software deployment.
5. USE_ENV_MODULES
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow uses '(environment) modules' for software deployment. This typically only applies to HPC infrastructures.
6. USE_SINGULARITY
    - datatype: <class 'bool'>
    - documentation: Represents the info if the workflow uses Singularity (Apptainer) for software deployment.

## Module: commons::30-settings::20-environment::05_paths.smk

**Module file**: `workflow/rules/commons/30-settings/20-environment/05_paths.smk`

### Documentation level: GLOBALVAR

1. DIR_BENCHMARK
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `rsrc` in the `WORKDIR`. Alias for DIR_RSRC.
2. DIR_CLUSTERLOG_ERR
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `log/cluster_jobs/err` in the `WORKDIR`. Only relevant in HPC environments. Intended to capture all stderr streams of executed rules/jobs (if applicable).
3. DIR_CLUSTERLOG_OUT
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `log/cluster_jobs/out` in the `WORKDIR`. Only relevant in HPC environments. Intended to capture all stdout streams of executed rules/jobs (if applicable).
4. DIR_ENVS
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Fully resolved directory path to `[..]/workflow/envs`. Any Conda environment yaml file used by the workflow can thus be addressed via `DIR_ENVS.joinpath(...)`.
5. DIR_GLOBAL_REF
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `global_ref` in the `WORKDIR`. This default directory is the source location for all reference data files that are *not* being produced by the workflow itself.
6. DIR_LOCAL_REF
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `local_ref` in the `WORKDIR`. This default directory is the target and source location for all reference data files that are produced programmatically by the workflow itself. In other words, for each file in `local_ref`, there must be a rule in the workflow that produces that file.
7. DIR_LOG
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `log` in the `WORKDIR`. All log files of the workflow can be addressed via `DIR_LOG.joinpath(...)` in Snakemake rules.
8. DIR_PROC
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `proc` in the `WORKDIR`. All non-result files of the workflow can be addressed via `DIR_PROC.joinpath(...)` in Snakemake rules.
9. DIR_REPO
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Recommended alias/shorthand for `DIR_REPOSITORY`, i.e. the fully resolved directory path to the workflow repository. By convention, this is always taken to be the parent of the `workflow/` directory.
10. DIR_RES
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `results` in the `WORKDIR`. All result files of the workflow can be addressed via `DIR_RES.joinpath(...)` in Snakemake rules.
11. DIR_RSRC
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Relative path pointing to `rsrc` in the `WORKDIR`. All resource ('benchmark') files of the workflow can be addressed via `DIR_LOG.joinpath(...)` in Snakemake rules.
12. DIR_SCRIPTS
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Fully resolved directory path to `[..]/workflow/scripts`. Any script used by the workflow can thus be addressed via `DIR_SCRIPTS.joinpath(...)`. See also the `get_script` function.
13. DIR_SNAKEFILE
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Fully resolved directory path in which the workflow's main snakefile resides. By convention, this path always ends with the last component `workflow/`.
14. DIR_WORKING
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Recommended global variable representing the fully resolved path to the Snakemake working directory, i.e. the content of the `--directory` / `-d` command line parameter. **CAUTION**: this parameter should only be used if absolutely necessary. All relevant directory paths should be addressed via the other global variables of this module.
15. NAME_SNAKEFILE
    - datatype: <class 'str'>
    - documentation: Name of the workflow's main snakefile, which is always `Snakefile` by convention / best practices.
16. PATH_SNAKEFILE
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Fully resolved file path of the workflow's main snakefile.
17. WORKDIR
    - datatype: <class 'pathlib.PosixPath'>
    - documentation: Alias/shorthand for `DIR_WORKING`.

### Documentation level: DEVONLY

1. WD_PATHS_MUST_RESOLVE
    - datatype: <class 'bool'>
    - documentation: If the workflow is executed with `--config devmode=True`, non-existing default paths are ignored and do not raise an error.

## Module: commons::40-pyutils::05_simple_get.smk

**Module file**: `workflow/rules/commons/40-pyutils/05_simple_get.smk`

### Documentation level: GLOBALFUN

1. find_script
    - datatype: <class 'function'>
    - documentation: 
```
    Original version of 'get_script'.

    DEPRECATED FUNCTION --- see 'get_script'
    
```
2. get_hostname
    - datatype: <class 'function'>
    - documentation: 
```
    Returns:
        host (str): name of host machine
    
```
3. get_script
    - datatype: <class 'function'>
    - documentation: 
```
    Utility function to locate script files underneath
    DIR_SCRIPTS. The intended usage context is inside
    a 'params' block, i.e.:

    rule rule_with_script:
            [...]
        params:
            script = get_script("script_name")
        shell:
            '{params.script} [...do scripted task...]'

    Args:
        script_name (str): file name of the script to be located
        extension (str): file extension of the script to be locate; default 'py'

    Returns:
        selected_script (str): full path to script file

    Raises:
        ValueError: no script or more than one match found

    
```
4. get_timestamp
    - datatype: <class 'function'>
    - documentation: 
```
    Get naive (not timezone-aware)
    timestamp representing 'now'.
    The formatting is following
    ISO 8601 w/o timezone offset, i.e.
    YYYY-MM-DDThh-mm-ss
    (24-hour format for time)

    Returns:
        ts (str): timestamp of 'now' w/o tz
    
```
5. get_username
    - datatype: <class 'function'>
    - documentation: 
```
    Returns:
        user (str): login name of current user
    
```

## Module: commons::40-pyutils::15_simple_logging.smk

**Module file**: `workflow/rules/commons/40-pyutils/15_simple_logging.smk`

### Documentation level: GLOBALFUN

1. log_err
    - datatype: <class 'function'>
    - documentation: 
```
    Alias for 'loggerr'
    
```
2. log_out
    - datatype: <class 'function'>
    - documentation: 
```
    Alias for 'logout'
    
```
3. logerr
    - datatype: <class 'function'>
    - documentation: 
```
    Log a message to sys.stderr.
    If VERBOSE is set, the level is
    set to 'VERBOSE (err/dbg)' and to
    'ERROR' otherwise. The message is
    prefixed with the current timestamp.

    Args:
        msg (str): message text

    Returns:
        None
    
```
4. logout
    - datatype: <class 'function'>
    - documentation: 
```
    Log a message to sys.stdout with level
    INFO. The message is prefixed with
    the current timestamp.

    Args:
        msg (str): message text

    Returns:
        None
    
```
5. write_log_message
    - datatype: <class 'function'>
    - documentation: 
```
    Log a message with info 'level' to 'stream',
    which must support a write method. By default,
    the 'message' is prefixed with the current timestamp.

    TODO - introduce enum type for levels?
    Level should be informative such as ERROR,
    WARNING, DEBUG and so on but is not sanity-checked.

    Args:
        stream (object): must support write method
        level (str): informative severity level
        message (str): the message to be logged

    Returns:
        None
    
```

