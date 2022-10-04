import datetime
import getpass
import pathlib
import subprocess
import sys


def logerr(msg):
    write_log_message(sys.stderr, "ERROR", msg)
    return


def logout(msg):
    write_log_message(sys.stdout, "INFO", msg)
    return


def get_username():
    user = getpass.getuser()
    return user


def get_timestamp():
    # format: ISO 8601
    ts = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    return ts


def write_log_message(stream, level, message):
    # format: ISO 8601
    ts = get_timestamp()
    fmt_msg = f"{ts} - LOG {level}\n{message.strip()}\n"
    stream.write(fmt_msg)
    return


def find_script(script_name, extension="py"):

    predicate = lambda s: script_name == s.stem or script_name == s.name

    # DIR_SCRIPTS is set in common/constants
    all_scripts = DIR_SCRIPTS.glob(f"**/*.{extension.strip('.')}")
    retained_scripts = list(map(str, filter(predicate, all_scripts)))
    if len(retained_scripts) != 1:
        if len(retained_scripts) == 0:
            err_msg = (
                f"No scripts found or retained starting at '{DIR_SCRIPTS}' "
                f" and looking for '{script_name}' [+ .{extension}]"
            )
        else:
            ambig_scripts = "\n".join(retained_scripts)
            err_msg = f"Ambiguous script name '{script_name}':\n{ambig_scripts}\n"
        raise ValueError(err_msg)
    selected_script = retained_scripts[0]

    return selected_script


def rsync_f2d(source_file, target_dir):
    """
    Convenience function to 'rsync' a source
    file into a target directory (file name
    not changed) in a 'run' block of a
    Snakemake rule.
    """
    abs_source = pathlib.Path(source_file).resolve(strict=True)
    abs_target = pathlib.Path(target_dir).resolve(strict=False)
    abs_target.mkdir(parents=True, exist_ok=True)
    _rsync(str(abs_source), str(abs_target))
    return


def rsync_f2f(source_file, target_file):
    """
    Convenience function to 'rsync' a source
    file to a target location (copy file
    and change name) in a 'run' block of
    a Snakemake rule.
    """
    abs_source = pathlib.Path(source_file).resolve(strict=True)
    abs_target = pathlib.Path(target_file).resolve(strict=False)
    abs_target.parent.mkdir(parents=True, exist_ok=True)
    _rsync(str(abs_source), str(abs_target))
    return


def _rsync(source, target):
    """
    Abstract function realizing 'rsync' calls;
    do not call this function, use 'rsync_f2f'
    or 'rsync_f2d'.
    """
    cmd = ["rsync", "--quiet", "--checksum", source, target]
    try:
        _ = subprocess.check_call(cmd, shell=False)
    except subprocess.CalledProcessError as spe:
        logerr(f"rsync from '{source}' to '{target}' failed")
        raise spe
    return


def _check_git_available():

    try:
        git_version = subprocess.check_output("git --version", shell=True)
        git_version = git_version.decode().strip()
        if VERBOSE:
            logerr(f"DEBUG: git version {git_version} detectedin $PATH")
        git_in_path = True
    except subprocess.CalledProcessError:
        git_in_path = False
    return git_in_path


def _extract_git_remote():
    """
    Function to extract the (most likely) primary
    git remote name and URL (second part, split at ':').
    Applies following priority filter:

    1. github - CUBI convention
    2. githhu - CUBI convention
    3. origin - git default
    4. <other> (first in list, issues warning if VERBOSE is set)

    Returns:
        tuple of str: remote name, URL

    Raises:
        subprocess.CalledProcessError: if git executable
        is not available in PATH
        ValueError: if no git remotes are configured for the repo
    """

    try:
        remotes = subprocess.check_output(
            "git remote -v", shell=True, cwd=DIR_SNAKEFILE
        )
        remotes = remotes.decode().strip().split("\n")
        remotes = [tuple(r.split()) for r in remotes]
    except subprocess.CalledProcessError:
        error_msg = "ERROR:\n"
        error_msg += "Most likely, 'git' is not available in your $PATH\n."
        error_msg += (
            f"Alternatively, this folder {DIR_SNAKEFILE} is not a git repository."
        )
        logerr(warning_msg)
        raise

    if not remotes:
        raise ValueError(f"No git remotes configured for repository at {DIR_SNAKEFILE}")

    remote_priorities = {"github": 0, "githhu": 1, "origin": 2}

    # sort list of remotes by priority,
    # assign high rank / low priority to unexpected remotes
    remotes = sorted(
        [(remote_priorities.get(r[0], 10), r) for r in remotes if r[-1] == "(fetch)"]
    )
    # drop priority value
    remote_info = remotes[0][1]
    remote_name, remote_url, _ = remote_info
    remote_url = remote_url.split(":")[-1]

    if remote_name not in remote_priorities and VERBOSE:
        warning_msg = f"WARNING: unexpected git remote (name: {remote_name}) assumed to be primary."

    return remote_name, remote_url


def collect_git_labels():
    """
    Collect some basic information about the
    checked out git repository of the workflow
    """

    label_collection = {
        "git_remote": "unset-error",
        "git_url": "unset-error",
        "git_short": "unset-error",
        "git_long": "unset-error",
        "git_branch": "unset-error",
    }

    git_in_path = _check_git_available()

    if git_in_path:

        primary_remote, remote_url = _extract_git_remote()
        label_collection["git_remote"] = primary_remote
        label_collection["git_url"] = remote_url

        collect_options = [
            "rev-parse --short HEAD",
            "rev-parse HEAD",
            "rev-parse --abbrev-ref HEAD",
        ]
        info_labels = ["git_short", "git_long", "git_branch"]

        for option, label in zip(collect_options, info_labels):
            call = "git " + option
            try:
                # Important here to use DIR_SNAKEFILE (= the git repo location)
                # and not WORK_DIR, which would be the pipeline working directory.
                out = subprocess.check_output(call, shell=True, cwd=DIR_SNAKEFILE)
                out = out.decode().strip()
                assert label in label_collection
                label_collection[label] = out
            except subprocess.CalledProcessError as err:
                err_msg = f"\nERROR --- could not collect git info using call: {call}\n"
                err_msg += f"Error message: {str(err)}\n"
                err_msg += f"Call executed in path: {DIR_SNAKEFILE}\n"
                logerr(err_msg)

    git_labels = [(k, v) for k, v in label_collection.items()]

    return git_labels
