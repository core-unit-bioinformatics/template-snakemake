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


def _collect_git_remotes(): 
    """
    Function to gather all available git remotes and then
    extracting the url of the repository based on the priority order
    1. github; 2. git.hhu; 3. origin.
    """
    wd = DIR_SNAKEFILE
    try:
        remotes = subprocess.check_output("git remote -v", shell=True, cwd=wd).decode().split()
    except:
            warning_msg = f"Warning:\n"
            warning_msg += f"It seems git is not an executable in your PATH\n"
            sys.stderr.write(warning_msg)
            pass


    Github_remote = 'github'
    GitLab_remote = 'git.hhu'
    origin_remote = 'origin'

    try:
        remotes_out = [git_remote for git_remote in remotes if Github_remote in git_remote][0]
    except IndexError:
        try:
            remotes_out = [git_remote for git_remote in remotes if GitLab_remote in git_remote][0]
        except IndexError:
            try:
                origin = remotes.index(origin_remote)
                remotes_out = remotes[origin+1]
            except ValueError:
                err_msg = f"Error message:\n"
                err_msg += f"No repository could be found\n"
                remotes_out = err_msg
                sys.stderr.write(err_msg)
    return remotes_out

def _collect_git_labels():

    try:
        subprocess.check_output("git remote -v", shell=True)
    except:
            warning_msg = f"Warning:\n"
            warning_msg += f"It seems git is not an executable in your PATH\n"
            sys.stderr.write(warning_msg)
            pass

    wd = DIR_SNAKEFILE

    collect_infos = [
        "rev-parse --short HEAD",
        "rev-parse --abbrev-ref HEAD",
    ]
    info_labels = ["git_hash", "git_branch"]

    git_labels = []
    for option, label in zip(collect_infos, info_labels):
        call = "git " + option
        try:
            out = subprocess.check_output(call, shell=True, cwd=wd).decode().strip()
            git_labels.append((label, out))
        except subprocess.CalledProcessError as err:
            err_msg = f"\nERROR --- could not collect git info using call: {call}\n"
            err_msg += f"Error message: {str(err)}\n"
            err_msg += f"Call executed in path: {wd}\n"
            err_msg += f"Proceeding with container building...\n"
            sys.stderr.write(err_msg)
            git_labels.append((label, "unset-error"))
    git_labels.append(tuple(["git_url",_collect_git_remotes()]))
    return git_labels
