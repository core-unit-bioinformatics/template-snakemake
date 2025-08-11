# Documentation for Snakemake workflow NAME HERE

**Note to developers**: Describe the purpose of the workflow (the big picture)

## User documentation

### Core functionality of the template

All standard workflows of the CUBI implement the same user
interface (or at least aim for a highly similar interface).
Hence, before [executing the workflow](template/running.md),
we strongly recommend reading the through the documentation
that explains how we help you to keep track of your analysis
results; we refer to this concept as
[**"file accounting"**](template/accounting.md). This feature
of standard CUBI workflows enables the pipeline to auto-
matically create a so-called [**"manifest"** file](template/accounting.md)
for your analysis run.

In case of questions, please open a GitHub issue in the repository
of the workflow you are trying to execute.

**Note to developers**: the above is the templated user documentation;
make sure to update or link to additional documentation, e.g.
describing workflow-specific parameters etc.

### Workflow-specific configuration and functionality

**Note to developers**: add workflow-specific documentation
to this section or link to Markdown documents
*organized under `docs/workflow`* in case of a more
extensive documentation.

## Developer documentation

Besides reading the user documentation, CUBI developers find more
information regarding standadized workflow development in the
[developer notes](template/developing.md). Please keep in mind
to always cross-link that information with the guidelines
published in the
[CUBI knowledge base](https://github.com/core-unit-bioinformatics/knowledge-base/wiki/).

Please raise any issues with these guidelines "close to the code",
i.e., either open an issue in the
[knowledge base repo](https://github.com/core-unit-bioinformatics/knowledge-base)
or in the affected repo for more specific cases.
