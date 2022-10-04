# some constants built from the Snakemake
# command line arguments
include: "commons/01_constants.smk"
# Module containing generic
# Python utility functions
include: "commons/02_pyutils.smk"
# Module containing generic
# Snakemake utility rules, e.g., dump_config
include: "commons/03_smkutils.smk"
# Module containing
# reference container location information
include: "commons/05_refcon.smk"
