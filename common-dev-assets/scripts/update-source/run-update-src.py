#!/usr/bin/env python3

import glob
import os
import re

import git
import requests

###########################################################################################################
# Constants
###########################################################################################################

# text to be searched in files
SEARCH_PATTERN_TIM = (
    r'(.*[Rr]eplace.*\n)?.*"?git::https:\/\/github\.com\/terraform-ibm-modules\/'
)
SEARCH_PATTERN_GE = (
    r'(.*[Rr]eplace.*\n)?.*"?git::https:\/\/github\.ibm\.com\/GoldenEye\/'
)
# variable to store the text that we want to replace in files
REPLACE_TEXT = '  source  = "'
FILES_TO_BE_SEARCHED = ["**/*.tf", "**/*.md"]
# terraform registry APIs
MODULE_REGISTRY_URL = "https://registry.terraform.io/v1/modules/terraform-ibm-modules/"
MODULE_SEARCH_URL = (
    "https://registry.terraform.io/v1/modules/search?q=terraform-ibm-modules%20"
)
EXCLUDE_DIRECTORIES = ["common-dev-assets", "ci"]

###########################################################################################################
# Core Logic
###########################################################################################################


# get the current working repo
def get_repo() -> str:
    """Gets the current working repository name

    Args:

    Returns:
        string: current working repo name
    """

    repo = git.Repo(os.getcwd())
    repo_name = repo.remotes.origin.url
    return repo_name


# get source information from terraform registry
def get_response(repo_name: str) -> dict:
    """Get response from terraform registry using
        1. repo_name
        2. if no response is returned using repo_name, get response using query string

    Args:
        repo_name(str): Name of the repository to query against terraform registry API

    Returns:
        dict: object with repo registry details
    """
    try:
        # search using namespace/name/provider
        response = requests.get(MODULE_REGISTRY_URL + repo_name + "/ibm")
        if response.status_code != 200:
            # search using query string
            response = requests.get(
                MODULE_SEARCH_URL + repo_name + "&limit=2&provider=ibm"
            )
        response.raise_for_status()
        return response.json()
    except requests.HTTPError as err:
        print(f"HTTP error occurred: {err}")
        return None
    except Exception as err:
        print(f"An error occurred: {err}")
        return None


# scans md, tf files and returns files to be updated
def get_files(
    extension: str, search_pattern: str, files: list, matched_lines: list
) -> tuple[set[str], set[str]]:
    """Get all the files to be updated with new source information

    Args:
        extension(str): current file pattern to be searched
        search_pattern(str): search for the given pattern
        files(list): list of files to be updated
        matched_lines(list): lines from the files which are to be updated

    Returns:
        list(str): list of files and the lines in the files to be updated
    """

    for file in glob.glob(extension, recursive=True):
        directory_name = os.path.dirname(file)
        if not any(directory_name.startswith(prefix) for prefix in EXCLUDE_DIRECTORIES):
            with open(file, "r") as reader:
                for line in reader:
                    if re.search(search_pattern, line):
                        matched_lines.append(line)
                        files.append(file)
            reader.close()
    # return unique files and lines
    return set(files), set(matched_lines)


# replaces the source in the file content
def replace_source(
    current_file_pattern: str,
    file: str,
    line: str,
    repo_name: str,
    search_pattern: str,
    replace_text: str,
    store: list,
) -> str:
    """Updates source information in the given files to the one found in store

    Args:
       current_file_pattern(str): extension of the file being updated
       file(str): name of the file to be updated
       line(str): text from the file to be updated
       search_pattern(str): pattern to be searched in the file
       replace_text(str): text to be replaced in the file
       store(list): list of terraform-ibm-modules source references captured

    Returns:
        string: replaced content of the file
    """

    id, version = extract_repo_details(store, repo_name)
    if id is not None and version is not None:
        repo_id = id.rsplit("/", 1)[0] + '/ibm"'
        with open(file, "r") as reader:
            file_data = reader.read()
            if current_file_pattern == "**/*.tf":
                version_replace_text = '\n  version = "' + version + '"'
            elif re.search(r"<a name=", line):
                version_replace_text = " | " + version + " | "
                search_pattern = r"git::https:\/\/github\.com\/"
                replace_text = ""
                repo_id = id.rsplit("/", 1)[0] + "/ibm"
            else:
                version_replace_text = '\n  version = "latest" # Replace "latest" with a release version to lock into a specific release'
            # replace source reference
            file_data = re.sub(
                search_pattern + ".*" + repo_name + ".*",
                replace_text + repo_id + version_replace_text,
                file_data,
            )
        reader.close()
        return file_data


# write replaced text and save file
def write_data_to_file(file: str, data: str) -> None:
    """writes the updated content to the file

    Args:
       file(str): path to the file to be written
       data(str): contents to be written to the file

    Returns:
    """

    with open(file, "w") as f:
        f.write(data)
        f.close()


# extract the repo name
def extract_repo_name(repo_name: str, prefix: str = "terraform-ibm-") -> str:
    """extracts repo name from the current working repo url

    Args:
       repo_name(str): the repo origin url of the current working repository
       prefix(str): string used to identify the repository name in the URL

    Returns:
       string: extracted repository name
    """
    if prefix in repo_name:
        stripped_repo_name = repo_name.split(prefix)
    else:
        stripped_repo_name = repo_name.split("-module")
    for repo_name_part in stripped_repo_name:
        if repo_name_part != "":
            return repo_name_part.rstrip("/.").strip()


# check if repo exists in the local dictionary
def check_repo_exists(repo_name: str, store: list) -> bool:
    """checks if repository details has been pulled from terraform registry

    Args:
       repo_name(str): the repo name
       store(list): list of terraform-ibm-modules source references captured

    Returns:
       bool: true if repository information is stored
    """

    repo_check = False
    for storedata in store:
        for key, value in storedata.items():
            if re.search(repo_name, key):
                repo_check = True
    return repo_check


# extract id, repo name and version from local store
def extract_repo_details(store: list, repo_name) -> tuple:
    """extracts the repo name from local store of source references

    Args:
       store(list): list of terrafrom-ibm-modules source references captured

    Returns:
       tuple: id, repo name and version of the repository
    """
    id = None
    version = None
    for storedata in store:
        for key, value in storedata.items():
            if repo_name == key:
                id = value.rsplit("/", 1)[0]
                version = value.rsplit("/", 1)[1]
    return id, version


# get all referenced source information from terraform registry
def get_source_details(repo_name: str, store: list) -> list:
    """get terraform source information

    Args:
       repo_name(str): name of referenced repo
       store(list): list of terrafrom-ibm-modules source references captured

    Returns:
       list: list of terraform-ibm-modules source references
    """
    response = get_response(repo_name)
    if response is not None:
        if "name" in response:
            id = response["id"]
            idobj = {repo_name: id}
            # append response to store
            store.append(idobj)

        elif "modules" in response:
            if len(response["modules"]) > 0:
                id = response["modules"][0]["id"]
                idobj = {repo_name: id}
                # append response to store
                store.append(idobj)
    return store


###########################################################################################################
# Main
###########################################################################################################

if __name__ == "__main__":
    for current_file_pattern in FILES_TO_BE_SEARCHED:
        version_replace_text = None
        files = []
        store = []
        files, lines = get_files(current_file_pattern, SEARCH_PATTERN_TIM, [], [])
        files, lines = get_files(current_file_pattern, SEARCH_PATTERN_GE, files, lines)
        if len(files) > 0:
            for file in files:
                for line in lines:
                    tim_repo_name = re.sub(
                        r"\?ref.*\n", "", (line.rsplit("/", 1)[1]).rsplit(".git", 1)[0]
                    )
                    repo_name = extract_repo_name(tim_repo_name)
                    # check if store has referenced repo details
                    if check_repo_exists(repo_name, store) is False:
                        store = get_source_details(repo_name, store)
                    if len(store) > 0:
                        data = replace_source(
                            current_file_pattern,
                            file,
                            line,
                            repo_name,
                            SEARCH_PATTERN_TIM,
                            REPLACE_TEXT,
                            store,
                        )
                        if data is not None:
                            write_data_to_file(file, data)
                        data = replace_source(
                            current_file_pattern,
                            file,
                            line,
                            repo_name,
                            SEARCH_PATTERN_GE,
                            REPLACE_TEXT,
                            store,
                        )
                        if data is not None:
                            write_data_to_file(file, data)
            print("Source references are updated in " + current_file_pattern + " files")
        else:
            print("No " + current_file_pattern + " files found to update")
