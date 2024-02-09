#!/bin/bash
set -e
# GIT_INDEX_FILE is set when code is commited and it is picked by pre-commit hook when clones the repo. If repo with the same name is cloned then changes inside cloned repo are reflected to a hook in a case we use -a flag for `git commit`
unset GIT_INDEX_FILE

# Script checks if commit id of the git submodule in a PR branch is older than the one in a main branch or remote.
# If commit id is older then error is thrown.
# pseudocode:
#   if local_commit_id != main_branch_commit_id
#   then
#       get all submodule commit ids
#       iterate through commit ids
#           if local_commit_id is found before main_branch_commit_id then OK
#           else throw Error
#   else OK


function get_submodule_version() {
    git_submodule_name=$1
    IFS=$'\n'
    git_submodules=$(git submodule status)
    for item in $git_submodules
    do
       if [[ $item == *"${git_submodule_name}"* ]]; then
            submodule="${item:1}"
            submodule_id="${submodule%%common-dev-assets*}"
            break
        fi
    done
    echo "${submodule_id}" | xargs
}

function submodule_exists(){
    git_submodule_name=$1
    git_submodules=$(git submodule status)
    exists=false
    if [ -e ".gitmodules" ]
    then
        while IFS= read -r line ; do
            if [[ $line == *"${git_submodule_name}"* ]]; then
                exists=true
                break
            fi
        done <<< "${git_submodules}"
    fi
    echo "${exists}"
}

# GHA pipeline doesn't run pre-commit hooks on merge. Support travis and tekton pipelines only
is_merge_pipeline() {
    merge_pipeline=false
    # Travis (see https://docs.travis-ci.com/user/environment-variables)
    if [ "${TRAVIS}" == "true" ] && [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
        merge_pipeline=true

    # Tekton Toolchain (see https://cloud.ibm.com/docs/devsecops?topic=devsecops-devsecops-pipelinectl)
    elif [ -n "${PIPELINE_RUN_ID}" ] && [ "$(get_env pipeline_namespace)" == "ci" ]; then
        merge_pipeline=true
    fi
    echo "${merge_pipeline}"
}

function main() {
    # execute only if repo has common-dev-assets submodule and it is not merge pipeline
    git_submodule_name="common-dev-assets"
    git_submodule_exists=$(submodule_exists ${git_submodule_name})
    is_merge_pipeline=$(is_merge_pipeline)

    if [ "${git_submodule_exists}" = true ] && [ "${is_merge_pipeline}" = false ]
    then
        # current submodule version
        submodule_version_current=$(get_submodule_version ${git_submodule_name})
        echo "Current PR branch submodule version: ${submodule_version_current}"

        # get git remote url which is needed for a repo clone
        git_remote_url=$(git config --get remote.origin.url)

        # create temp folder and clone a repo
        temp_dir=$(mktemp -d)
        cd "${temp_dir}"
        git clone -q "${git_remote_url}"
        cd "$(ls)"

        # get primary branch submodule version
        git submodule update --init
        submodule_version_main_branch=$(get_submodule_version ${git_submodule_name})
        echo "Primary branch submodule version: ${submodule_version_main_branch}"

        if [ "${submodule_version_current}" != "${submodule_version_main_branch}" ]; then

            # get all git submodule commit ids. The list is sorted in descending order (the latest commit id is the first element)
            cd "${git_submodule_name}"
            git_submodule_commit_ids=$(git rev-list origin)

            while IFS= read -r git_submodule_commit_id
            do
                # if submodule_version_main_branch is found before submodule_version_current then the current submodule version is older than the primary branch version and script must fail
                if [ "${submodule_version_main_branch}" = "${git_submodule_commit_id}" ]; then
                    printf "\nDetected common-dev-assets git submodule commit ID is older than the one in primary branch. To fix:\n  1. Record the current state of the working directory:\n      i. git stash\n  2. Ensure that your local primary branch is up to date:\n      i. git checkout <master / main>\n      ii. git pull origin <master / main>\n      iii. git submodule update --rebase\n  3. Make sure your dev branch is rebased with remote primary branch:\n      i. git checkout <dev-branch>\n      ii. git stash pop\n      iii. git pull origin <master / main>\n  4. Run the following command to sync the git submodule with primary branch:\n      i. git submodule update --rebase\n\nAlternatively you can run 'git submodule update --remote --merge' to update your branch to the latest available git submodule, however this is not recommended, as you will likely soon end up with conflicts to resolve due to the renovate automation that is updating the git submodule version in primary branch very frequently."
                    rm -fr "${temp_dir}"
                    exit 1
                fi

                if [ "${submodule_version_current}" = "${git_submodule_commit_id}" ]; then
                    break
                fi
            done <<< "${git_submodule_commit_ids}"
        fi

        rm -fr "${temp_dir}"
    fi
}

main
