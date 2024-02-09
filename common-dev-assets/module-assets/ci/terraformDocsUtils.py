import os
import sys
from pathlib import Path
from subprocess import PIPE, Popen
from urllib.parse import urlparse


# create temp markdown which content is added to main README
def create_markdown(newlines, markdown):
    with open(markdown, "w") as writer:
        if len(newlines) > 0:
            for line in newlines:
                writer.writelines((str(line), "\n"))


#  remove temp markdown
def remove_markdown(markdown):
    if os.path.exists(markdown):
        os.remove(markdown)


# check if folder contains any tf file
def has_tf_files(path):
    if any(File.endswith(".tf") for File in os.listdir(path)):
        return True
    else:
        return False


# check if pre-commmit hook tag exists on main README.md
def is_hook_exists(hook_tag, md_file="README.md"):
    exists = False
    with open(md_file, "r") as reader:
        lines = reader.readlines()
        for line in lines:
            if hook_tag in line:
                exists = True
    return exists


# Return title (first line) of README file
def get_readme_title(readme_file):
    with open(readme_file, "r") as reader:
        line = reader.readline()
        return line


# get first line of all README files inside specific path
def get_readme_titles(path):
    readme_titles = []
    for readme_file in Path(path).rglob("README.md"):
        path = str(readme_file)
        # ignore README file if it has dot(.) in a path or the parent path does not contain any tf file
        if not ("/.") in path and has_tf_files(readme_file.parent):
            readme_title = get_readme_title(path)
            if readme_title:
                data = {"path": path, "title": readme_title}
                readme_titles.append(data)
    readme_titles.sort(key=lambda x: x["path"])
    return readme_titles


# get repository url
def get_module_url():
    get_repository_url_command = "git config --get remote.origin.url"
    proc = Popen(get_repository_url_command, stdout=PIPE, stderr=PIPE, shell=True)
    output, error = proc.communicate()
    full_url = output.decode("utf-8").strip()

    if proc.returncode != 0:
        print(error)
        sys.exit(proc.returncode)

    # urlparse can not be used for git urls
    if full_url.startswith("http"):
        output = urlparse(full_url)
        module_url = output.hostname + output.path
    else:
        module_url = full_url.replace("git@", "").replace(":", "/")

    return module_url.replace(".git", "")
