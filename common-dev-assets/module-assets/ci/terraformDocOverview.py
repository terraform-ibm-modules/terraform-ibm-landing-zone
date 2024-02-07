#!/usr/bin/python

import os
import pathlib
from pathlib import Path
from typing import List, Tuple

import terraformDocsUtils


# Check if a line is a heading
def get_title(
    line: str, code_block: bool, comment_block: bool
) -> Tuple[int, str, bool, bool]:
    level = 0
    for c in line:
        # set a flag to know if the lines are inside code block
        if "```" in line:
            code_block = not code_block
            break
        # one line comment, skip it
        elif "<!--" in line and "-->" in line:
            break
        # comment block begin -> set flag to true
        elif "<!--" in line:
            comment_block = True
            break
        # comment block end -> set flag to false
        elif "-->" in line:
            comment_block = False
            break
        # do not check lines if they are inside comment or code block
        elif code_block is False and comment_block is False:
            if c == "#":
                level += 1
            else:
                break
    title = line[level + 1 : -1]

    return (level, title, code_block, comment_block)


# get main readme headings
def get_main_readme_headings():
    with open("./README.md", "r") as f:
        code_block = False
        comment_block = False
        for line in f.readlines():
            level, title, code_block, comment_block = get_title(
                line, code_block, comment_block
            )
            code_block = code_block
            comment_block = comment_block

            # developing and contributing must be added to overview at level 0
            if "developing" == title.lower() or "contributing" == title.lower():
                level = 0
                data = "    " * (level) + "* [{}](#{})".format(
                    title, title.replace(" ", "-").lower()
                )
    return data


def get_headings(folder_name):
    readme_headings: List[str] = []
    if os.path.isdir(folder_name.lower()):
        for readme_file_path in Path(folder_name.lower()).rglob("README.md"):
            path = str(readme_file_path)
            # ignore README file if it has dot(.) in a path or the parent path does not contain any tf file
            if not ("/.") in path and terraformDocsUtils.has_tf_files(
                readme_file_path.parent
            ):
                if "modules" == folder_name:
                    # for modules bullet point name is folder name
                    data = "    * [{}](./{})".format(
                        path.replace("modules/", "").replace("/README.md", ""),
                        path.replace("/README.md", ""),
                    )
                else:
                    # for examples bullet point name is title in example's README
                    readme_title = terraformDocsUtils.get_readme_title(path)
                    if readme_title:
                        data = "    * [{}](./{})".format(
                            readme_title.replace("\n", "").replace("# ", ""),
                            path.replace("/README.md", ""),
                        )
                readme_headings.append(data)
    return sorted(readme_headings)


def add_to_overview(overview, folder_name):
    if os.path.isdir(folder_name.lower()):
        # add lvl 1 bullet point to an overview
        bullet_point = "* [{}](./{})".format(
            "Submodules" if folder_name == "Modules" else folder_name,
            folder_name.lower(),
        )
        overview.append(bullet_point)
        bullet_point_index = overview.index(bullet_point)

        # get headings
        readme_titles = get_headings(folder_name.lower())

        for index, readme_file_path in enumerate(readme_titles):
            # we need to add examples under Examples lvl 1 bullet point
            overview.insert(index + bullet_point_index + 1, readme_file_path)


def main():
    if terraformDocsUtils.is_hook_exists("<!-- BEGIN OVERVIEW HOOK -->"):
        overview: List[str] = []
        overivew_markdown = "overview.md"

        # add module name to an overview as a first element
        path = pathlib.PurePath(terraformDocsUtils.get_module_url())
        repo_name = path.name
        overview.append("* [{}](#{})".format(repo_name, repo_name))

        # add modules to "overview"
        add_to_overview(overview, "Modules")

        # add examples to "overview"
        add_to_overview(overview, "Examples")

        # add last heading of README (contributing (external) or developing (internal)) to overview
        overview.append(get_main_readme_headings())

        # create markdown
        terraformDocsUtils.create_markdown(overview, overivew_markdown)

        # run terraform docs
        os.system(
            "terraform-docs -c common-dev-assets/module-assets/.terraform-docs-config-overview.yaml ."
        )

        terraformDocsUtils.remove_markdown(overivew_markdown)


main()
