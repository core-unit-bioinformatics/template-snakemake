import datetime
import os
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
    user = os.getlogin()
    return user


def get_timestamp():
    # format: ISO 8601
    ts = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    return ts


def write_log_message(stream, level, message):
    # format: ISO 8601
    ts = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
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
    abs_source = pathlib.Path(source_file).resolve(strict=True)
    abs_target = pathlib.Path(target_dir).resolve(strict=False)
    abs_target.mkdir(parents=True, exist_ok=True)
    rsync(str(abs_source), str(abs_target))
    return


def rsync_f2f(source_file, target_file):
    abs_source = pathlib.Path(source_file).resolve(strict=True)
    abs_target = pathlib.Path(target_file).resolve(strict=False)
    abs_target.mkdir(parents=True, exist_ok=True)
    rsync(str(abs_source), str(abs_target))
    return


def rsync(source, target):

    cmd = ["rsync", "--quiet", "--checksum", source, target]
    try:
        _ = subprocess.check_call(cmd, shell=False)
    except subprocess.CalledProcessError as spe:
        logerr("rsync from {source} to {target} failed")
        raise spe
    return
