"""
The staging module is the right place to trigger
code executions that affect the state/env
the workflow is executed in and that need
to be executed before Snakemake starts
its actual work.

This is the only "commons" module that is
dependent on the other "commons" modules.
In other words, here, the series of
"include:" statements in "00_commons.smk"
matters.

Functions called here should be written
in a very defensive manner, and always
be tested in some way via "snaketests.smk"
"""

# reset accounting files if requested
_reset_file_accounts()
