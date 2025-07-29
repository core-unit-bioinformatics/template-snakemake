
WORKFLOW_OUTPUT = []

WORKFLOW_OUTPUT.extend(
    rules.test_all_pythonics.input
)

WORKFLOW_OUTPUT.extend(
    rules.test_all_file_io.input
)

WORKFLOW_OUTPUT.append(
    rules.test_refcon_functionality.output[0]
)

