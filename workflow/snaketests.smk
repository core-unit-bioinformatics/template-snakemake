include: "rules/00_modules.smk"

rule run_tests:
    input:
        RUN_CONFIG_RELPATH,
        DIR_RES.joinpath("testing", "all-ok.txt")


rule create_test_file:
    """
    Implicitly tests pyutil functions
    02_pyutils.smk::get_username
    02_pyutils.smk::get_timestamp
    """
    output:
        DIR_PROC.joinpath("testing", "ts-ok_user-ok.txt")
    run:
        timestamp = get_timestamp()
        user_id = get_username()
        content = "Running Snakemake tests\n"
        content += f"get_username: {user_id}\n"
        content += f"get_timestamp: {timestamp}\n"
        with open(output[0], "w") as testfile:
            testfile.write(content)
    # END OF RUN BLOCK


rule test_log_functions:
    """
    Test pyutil logging functions
    """
    output:
        DIR_PROC.joinpath("testing", "log-ok.txt")
    run:
        logout("Test log message to STDOUT")
        logerr("Test log message to STDERR")
        with open(output[0], "w") as testfile:
            testfile.write("Log test ok")
    # END OF RUN BLOCK


rule test_find_script_success:
    output:
        DIR_PROC.joinpath("testing", "success-find-script-ok.txt")
    params:
        script = find_script("test")
    run:
        # the following should never raise,
        # i.e. script_find() would fail before
        _ = pathlib.Path(params.script).resolve(strict=True)
        with open(output[0], "w") as testfile:
            testfile.write("find_script success test ok")
    # END OF RUN BLOCK


rule test_find_script_fail:
    output:
        DIR_PROC.joinpath("testing", "fail-find-script-ok.txt")
    run:
        try:
            script = find_script("non_existing")
            # the previous line should not succeed,
            # if we are here, we do not create the
            # output file of the test, and thus fail
        except ValueError:
            with open(output[0], "w") as testfile:
                testfile.write("find_script fail test ok")
    # END OF RUN BLOCK


rule test_rsync_f2d:
    input:
        rules.create_test_file.output
    output:
        DIR_PROC.joinpath("testing", "subfolder", "ts-ok_user-ok.txt")
    run:
        # first check that nobody changed the filename
        input_name = pathlib.Path(input[0]).name
        output_name = pathlib.Path(output[0]).name
        assert input_name == output_name
        output_dir = pathlib.Path(output[0]).parent
        rsync_f2d(input[0], output_dir)
    # END OF RUN BLOCK


rule test_rsync_f2f:
    input:
        rules.create_test_file.output
    output:
        DIR_PROC.joinpath("testing", "rsync-f2f-ok.txt")
    run:
        rsync_f2f(input[0], output[0])
    # END OF RUN BLOCK


rule test_rsync_fail:
    input:
        rules.create_test_file.output
    output:
        DIR_PROC.joinpath("testing", "rsync-fail-ok.txt")
    message: "EXPECTED FAILURE: ignore following rsync error message"
    run:
        import subprocess
        try:
            rsync_f2d(input[0], "/")
        except subprocess.CalledProcessError:
            with open(output[0], "w") as testfile:
                testfile.write("rsync fail test ok")
    # END OF RUN BLOCK


rule aggregate_tests:
    input:
        rules.create_test_file.output,
        rules.test_log_functions.output,
        rules.test_find_script_success.output,
        rules.test_find_script_fail.output,
        rules.test_rsync_f2f.output,
        rules.test_rsync_f2d.output,
        rules.test_rsync_fail.output
    output:
        DIR_RES.joinpath("testing", "all-ok.txt")
    run:
        with open(output[0], "w") as testfile:
            testfile.write("ok")
    # END OF RUN BLOCK

