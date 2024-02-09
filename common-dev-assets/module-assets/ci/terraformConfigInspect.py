#!/usr/bin/python

import glob
import shutil
import sys
from pathlib import Path
from subprocess import PIPE, Popen


def terraform_init_upgrade():
    tf_init_upgrade_command = "terraform init --upgrade"
    proc = Popen(tf_init_upgrade_command, stdout=PIPE, stderr=PIPE, shell=True)
    error = proc.communicate()
    if proc.returncode != 0:
        print(error)
        sys.exit(proc.returncode)


def get_terraform_provider():
    for terraform_provider in Path(".terraform").rglob("provider_metadata.json"):
        return terraform_provider


def run_metadata_generator(file_path, terraform_provider):
    tf_config_inspect_command = ""
    if terraform_provider:
        tf_config_inspect_command = "terraform-config-inspect --json --metadata %s" % (
            terraform_provider
        )
    else:
        tf_config_inspect_command = "terraform-config-inspect --json"

    proc = Popen(tf_config_inspect_command, stdout=PIPE, stderr=PIPE, shell=True)
    output, error = proc.communicate()

    if proc.returncode != 0:
        print(error)
        sys.exit(proc.returncode)
    else:
        with open(file_path, "wb") as binary_file:
            binary_file.write(output)


def remove_tf_IBM_provider():
    dirpath = Path(".terraform/providers/registry.terraform.io/ibm-cloud")
    if dirpath.exists() and dirpath.is_dir():
        shutil.rmtree(dirpath)


def main():
    if glob.glob("*.tf"):
        # remove IBM provider. Must be removed so we make sure that local terraform cache has the latest version only
        remove_tf_IBM_provider()

        # always run terraform init upgrade
        terraform_init_upgrade()

        # get IBM terraform provider
        terraform_provider = get_terraform_provider()

        # run metadata generator tool
        metadata_name = "module-metadata.json"
        run_metadata_generator(metadata_name, terraform_provider)


main()
