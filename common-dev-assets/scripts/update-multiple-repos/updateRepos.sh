#!/bin/bash
set -e

# A script which helps to update multiple repos with the same changes.
# To use a script successfully make all changes where TODO is a part of a comment.

# TODO: uncomment and replace:
# - <token>: with your github api key. For public GH use public key, while for private GHE use the private one
# - <email>: with your email
# export GITHUB_USER_EMAIL=<email>
# export GITHUB_TOKEN=<token>

# TODO: specify if you run a script against private GHE or public GH
IS_PRIVATE_GH=false

if [ "${IS_PRIVATE_GH}" = true ]
then
    # Private GHE
    GIT_URL="github.ibm.com/api/v3"
    GIT_ORG="GoldenEye"
    export GH_HOST=github.ibm.com
else
    #  Public GH
    GIT_URL="api.github.com"
    GIT_ORG="terraform-ibm-modules"
    export GH_HOST=github.com
fi

BASEURL="https:/${GIT_URL}/orgs/${GIT_ORG}/repos?per_page=200"
export GH_ENTERPRISE_TOKEN="$GITHUB_TOKEN"

# create .netrc for github authentication
function create_netrc {
    printf "\n#### CREATE .netrc ####\n\n"

    if ! grep -q "machine github.ibm.com" ~/.netrc; then
        echo -e "machine github.ibm.com\n  login $GITHUB_TOKEN" >> ~/.netrc
        # git config --global user.email "$GITHUB_USER_EMAIL"
        # git config --global user.name "${GITHUB_USER_EMAIL}"
        echo "Done."
    else
        echo "Found entry already exists in ~/.netrc for github.ibm.com. Taking no action."
    fi
}

# clone repo
function clone_repo() {
    printf "\n#### CLONE REPO ####\n\n"
    repo_name=$1
    if [ "${IS_PRIVATE_GH}" = true ]
    then
        git clone git@github.ibm.com:"${GIT_ORG}"/"${repo_name}".git
    else
        git clone https://github.com/"${GIT_ORG}"/"${repo_name}".git
    fi
}

function delete_path(){
    file_path=$1
    rm -fr "${file_path}"
    echo "${file_path} deleted."
}

function path_exists(){
    file_path="${1}"
    path_exists=false

    if [ -e "${file_path}" ]
    then
        path_exists=true
    fi
    echo "${path_exists}"
}

# create PR
# additonally you can add body to commit as `gh pr create --title "${commit_message}" --body "$body"`
function create_pr {
    printf "\n#### CREATE NEW PR ####\n\n"

    # TODO: specify branch name
    branch_name="remove_brewfile"
    # TODO: specify commit message
    commit_message="chore: remove Brewfile"
    # TODO: specify body PR. Be aware that adding custom body will override the default PR body.
    # Add '--body' flag to 'gh pr create' as: gh pr create --title "${commit_message}" --body "$pr_body"
    # pr_body="Issue: https://github.ibm.com/GoldenEye/issues/issues/4879";

    git checkout -b "$branch_name"
    git add .
    git commit -m "${commit_message}"
    if git push --set-upstream origin "$branch_name";
    then
    gh pr create --title "${commit_message}";
    else
        printf "\nPR can not be created.\n\n"
    fi
}

# get all repos of organization.
function get_repos(){
    curl --user "$GITHUB_USER_EMAIL:$GITHUB_TOKEN" "$BASEURL" > repos.json
}

# TODO: here specify what kind of changes you would like to add to repo.
# In the following example case we delete files version.tf and provider.tf.
function update_repo(){
    repo_name=$1
    printf "\n#### UPDATE REPO ####\n\n"
    printf "%s\n" "${repo_name}"


    rm -fr "${repo_name}"
    clone_repo "${repo_name}"
    cd "${repo_name}"

    create_pr=false
    files_to_delete=(version.tf provider.tf)

    printf "\n#### CHECK IF FILE/FOLDER EXISTS ####"
    for file_path in "${files_to_delete[@]}"
    do
        does_exist=$(path_exists "${file_path}")
        if [ "${does_exist}" = true ]
        then
            printf "\n\n%s exists. Remove it.\n" "${file_path}"
            delete_path "${file_path}"
            create_pr=true
        else
            printf "\n\nRepo %s does not have %s. Skip.\n" "${repo_name}" "${file_path}"
        fi
    done

    # creates a new PR with changes
    if [ ${create_pr} == "true" ]
    then
        create_pr
    fi

    cd "${BASEDIR}"
    rm -fr "${repo_name}"
}

function main() {
    BASEDIR=$(pwd)
    if [ "${IS_PRIVATE_GH}" = true ]
    then
        create_netrc
    fi

    get_repos

    # list all repo names
    # shellcheck disable=SC2207
    goldeneye_repos=($(jq -r '.[] | .name' repos.json))

    # skip automation for specific repos
    # TODO: add more repositories if you want to skip them
    skip_repos=("module-template terraform-ibm-module-template issues common-dev-assets")

    for repo_name in "${goldeneye_repos[@]}"
    do
        if [[ ! " ${skip_repos[*]} " =~ ${repo_name} ]]; then
            update_repo "${repo_name}"
        fi
    done
    rm -f repos.json
}

main
