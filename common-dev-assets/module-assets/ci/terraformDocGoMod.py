#!/usr/bin/python

import re
from pathlib import Path

import terraformDocsUtils


# Set go.mod file with the correct module repo
def set_go_mod(path, module_url):
    with open(path, "r") as file:
        lines = file.readlines()
    if len(lines) > 0:
        expected_line = "module " + module_url
        replace_module = False
        for index, line in enumerate(lines):
            regex = re.search(r"module.*?github.*?", line)
            if regex:
                regex_result = regex.string.strip()
                if regex_result.lower() != expected_line.lower():
                    print(
                        "current value: {}\nnew value    : {}".format(
                            regex_result.lower(), expected_line.lower()
                        )
                    )
                    replace_module = True
                    break
        if replace_module:
            lines[index] = expected_line + "\n"
            with open(path, "w") as writer:
                writer.writelines(lines)
            print(
                "\nwarning: If repository name has changed, then update 'remote.origin.url' locally by running 'git remote set-url origin new_repo_url' or re-clone the repo using the new repo name."
            )


# modify module url to internal or external repo
def change_module_url(module_url):
    git_owner = "terraform-ibm-modules"
    if "github.ibm.com" in module_url:
        git_owner = "GoldenEye"
    return re.sub(
        "/.*/",
        lambda x: x.group(0).replace(x.group(0), "/%s/" % (git_owner)),
        module_url,
    )


def main():
    go_mod_path = Path("tests/go.mod")
    if go_mod_path.is_file():
        module_url = change_module_url(terraformDocsUtils.get_module_url())
        if module_url:
            set_go_mod(go_mod_path, module_url)


main()
