# Parameter and function docs for context: TEMPLATE

## Module: commons::05_docgen.smk

**Module file**: workflow/rules/commons/05_docgen.smk

### Documentation level: GLOBALOBJ

1. DOCREC
    - datatype: <class 'snakemake.workflow.DocRecorder'>
    - documentation: Alias/short hand for DOC_RECORDER.
2. DOC_RECORDER
    - datatype: <class 'snakemake.workflow.DocRecorder'>
    - documentation: Instance of the `DocRecorder` class that is globally available to record documentation *in place*. The DocRecorder class has two member functions to record documentation about 'objects' (in the Python sense) in module contexts. At the beginning of each module, call the function `DOC_RECORDER.add_module_doc(...)` to start a new module context. After that, call the function `DOC_RECORDER.add_member_doc(...)` for each member ('object' in the Python sense) of the module that you want to document. The documentation is dumped as a Markdown file and thus supports (basic) Markdown syntax for emphasis etc. In order to generate the documentation, execute the workflow with the target rule `run_build_docs`.
3. DocContext
    - datatype: <class 'enum.EnumType'>
    - documentation: Enum listing the different documentation contexts, which is currently limited to TEMPLATE and WORKFLOW. The context is used to sort the dumped documentation Markdown file into 'docs/template' or 'docs/workflow'.
4. DocLevel
    - datatype: <class 'enum.EnumType'>
    - documentation: Enum listing the different documentation levels such as USERCONFIG and GLOBALVAR that need to be specified when documenting module 'members'. See documentation of the DOC_RECORDER object for more details.

## Module: commons::10-constants::00_legacy.smk

**Module file**: workflow/rules/commons/10-constants/00_legacy.smk

### Documentation level: DEVONLY

1. SNAKEMAKE_LEGACY_RUN
    - datatype: <class 'bool'>
    - documentation: This variable can be checked if it is critical to determine whether or not the workflow is executed with a Snakemake legacy version (typically v7) or with a more recent release (typically v9+).

