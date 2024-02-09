#!/usr/bin/python

import os

import terraformDocsUtils


def prepare_lines(readme_titles, newlines):
    if len(readme_titles) > 0:
        for readme_title in readme_titles:
            prepare_line = (
                "- ["
                + readme_title["title"].strip().replace("#", "")
                + "]("
                + readme_title["path"].replace("/README.md", "")
                + ")"
            )
            newlines.append(prepare_line)
    else:
        prepare_line = "- [Examples](examples)\n"
        newlines.append(prepare_line)


def run_terraform_docs():
    os.system(
        "terraform-docs -c common-dev-assets/module-assets/.terraform-docs-config-examples.yaml ."
    )


def main():
    examples_markdown = "EXAMPLES.md"
    if os.path.isdir("examples") and terraformDocsUtils.is_hook_exists(
        "BEGIN EXAMPLES HOOK"
    ):
        newlines = []
        readme_titles = terraformDocsUtils.get_readme_titles("examples")
        prepare_lines(readme_titles, newlines)
        terraformDocsUtils.create_markdown(newlines, examples_markdown)
        run_terraform_docs()
        terraformDocsUtils.remove_markdown(examples_markdown)


main()
