#!/usr/bin/python

import os
import sys
from pathlib import Path
from subprocess import PIPE, Popen

import terraformDocsUtils


def modify_temp_markdown_file(temp_markdown: str) -> list[str]:
    # temp markdowns
    markdown = "tf-docs.md"
    temp_markdowns = []

    # Find all previously generated temp markdowns and modify them
    for root, dirnames, filenames in os.walk("."):
        for name in filenames:
            if name == temp_markdown:
                # get full markdowns path
                markdown_path = os.path.join(root, temp_markdown)
                new_markdown_path = os.path.join(root, markdown)

                # save all temp markdowns for later to be delete it
                temp_markdowns.append(markdown_path)
                temp_markdowns.append(new_markdown_path)

                # change headings from lvl 2 to lvl 3 and save tf docs content into new temp file
                with open(markdown_path, "rt") as reader:
                    with open(new_markdown_path, "wt") as writer:
                        for line in reader:
                            # tf_docs adds BEGIN_TF_DOCS and END_TF_DOCS metatags to a markdown content by default. We do not need this, since we have own metatag
                            if not ("BEGIN_TF_DOCS" in line or "END_TF_DOCS" in line):
                                writer.write(line.replace("##", "###"))
    return temp_markdowns


# find all README files that have pre-commit hook metatag
def get_valid_readme_paths() -> list[str]:
    paths = []
    dir = os.getcwd()
    hook_tag = "<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->"
    for readme_file in Path(dir).rglob("README.md"):
        path = str(readme_file)
        if not ("/.") in path and terraformDocsUtils.is_hook_exists(hook_tag, path):
            paths.append(str(readme_file.parent))
    return paths


# run tf_docs against a folder where valid README file exists
def update_readme(path: str):
    # temp markdown name
    temp_markdown = "temp-tf-docs.md"

    # list of temporary markdown files
    temp_markdowns = []

    # create temp markdown with tf_docs content
    command = f"terraform-docs --hide providers markdown table --output-file {temp_markdown} {path}"
    proc = Popen(command, stdout=PIPE, stderr=PIPE, shell=True)
    proc.communicate()

    # hard fail if error occurs
    if proc.returncode != 0:
        print(f"Error creating temp markdowns: {proc.communicate()[1]}")
        sys.exit(proc.returncode)

    # modify and prepare temp markdown file
    temp_markdowns = modify_temp_markdown_file(temp_markdown)

    # add temp markdown content to README file
    command = f"terraform-docs -c common-dev-assets/module-assets/.terraform-docs-config.yaml {path}"
    proc = Popen(command, stdout=PIPE, stderr=PIPE, shell=True)
    proc.communicate()

    # hard fail if error occurs
    if proc.returncode != 0:
        print(f"Error adding content to README: {proc.communicate()[1]}")
        for markdown in temp_markdowns:
            terraformDocsUtils.remove_markdown(markdown)
        sys.exit(proc.returncode)

    # remove all temp markdowns
    for markdown in temp_markdowns:
        terraformDocsUtils.remove_markdown(markdown)


def main():
    paths = get_valid_readme_paths()
    for path in paths:
        update_readme(path)


main()
