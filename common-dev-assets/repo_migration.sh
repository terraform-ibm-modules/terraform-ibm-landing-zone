#!/bin/bash
# This script can be used to migrate the existing repositories to follow the same format as the repository template https://github.com/terraform-ibm-modules/terraform-ibm-module-template

BASE_REPO_URL="https://github.com/terraform-ibm-modules/"
BRANCH="main"
ARCHIVE="/archive/refs/heads/${BRANCH}.zip"
REPO_TEMPLATE="terraform-ibm-module-template"
REPO_TEMPLATE_URL="${BASE_REPO_URL}${REPO_TEMPLATE}${ARCHIVE}"
TEMP_DIR=$(mktemp -d)

function confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            echo "yes"
            ;;
        *)
            echo "no"
            ;;
    esac
}

function validate_prereqs(){
  echo "Validating pre reqs..."
  REQS=("git" "python3" "go" "curl" "unzip" )

  # Iterate the string array using for loop
  for val in "${REQS[@]}"; do
     if ! [ -x "$(command -v "${val}")" ]; then
       echo "Error: ${val} is not installed." >&2
       exit 1
     fi
  done
  echo "Complete"

}

function check_correct_repo() {
   REPO=$(git config --get remote.origin.url)
   if [[ "yes" != $(confirm "Are you sure you want to migrate ${REPO} [y/N]?") ]]
   then
     echo "exiting"
     exit 1
   fi
}

# Download template
function download_template() {
    echo "Downloading template from ${REPO_TEMPLATE_URL}"
    curl -L -O --output-dir "${TEMP_DIR}" "${REPO_TEMPLATE_URL}"
    unzip "${TEMP_DIR}/*.zip" -d "${TEMP_DIR}"
}

# Cleanup
function clean_up() {
  echo "Cleaning up"
  rm -rf "${TEMP_DIR}"
}

# Add git settings/pipelines
function add_git_settings() {
    echo "Adding git settings"
    cp -r "${TEMP_DIR}/${REPO_TEMPLATE}-${BRANCH}/.github" .
    git add ".github"
}

# Add git submodule
function add_git_submodule() {
    echo "Add git submodule"
    touch ".gitmodules"
    git submodule add --force https://github.com/terraform-ibm-modules/common-dev-assets.git
    git add ".gitmodules"
    echo "Submodule Init"
    git submodule update --init

}

# Create Symbolic links
function create_symbolic_links() {
    echo "Creating symbolic links"
    for file in ".pre-commit-config.yaml" "Makefile" "ci"; do
      if [ -f "${file}" ]
      then
        if [[ "yes" == $(confirm "Replace ${file} [y/N]? (Required for migration)") ]]
        then
          rm -rf "${file}"
        fi
      fi
    done

    ln -s common-dev-assets/module-assets/.pre-commit-config.yaml .pre-commit-config.yaml
    git add .pre-commit-config.yaml
    ln -s common-dev-assets/module-assets/ci ci
    git add ci
    ln -s common-dev-assets/module-assets/Makefile Makefile
    git add Makefile

}

# Add Examples
function add_example() {
    ADD_EXAMPLE="yes"
    if [ -f "examples" ]
    then
      ADD_EXAMPLE=$(confirm "examples directory already exists. Do you want to add the sample example anyway ${file} [y/N]?")
    fi

    if [[ "yes" == "${ADD_EXAMPLE}" ]]
    then
      echo "Adding example"
      cp -r "${TEMP_DIR}/${REPO_TEMPLATE}-${BRANCH}/examples" .
      git add examples
    fi

    until [[ "no" == $(confirm "Do you have existing examples you would like to move to examples directory [y/N]?") ]]
    do
      read -r -p "Please enter path of directory to move " response
      mv "${response}" examples/
    done
}

# Add Tests
function add_tests() {
    ADD_TESTS="yes"
    if [ -f "tests" ]
    then
      ADD_TESTS=$(confirm "tests directory already exists. Do you want to add the sample tests anyway ${file} [y/N]?")
    fi

    if [[ "yes" == "${ADD_TESTS}" ]]
    then
      echo "Adding tests"
      cp -r "${TEMP_DIR}/${REPO_TEMPLATE}-${BRANCH}/tests" .
      git add tests
    fi
}

# Local init
function local_init() {
  echo "Local initialization"
  make
}

if [[ "$1" == "-r"  || "$1" == "-R" ]]
then
    echo "Attempting to remove migration"
    rm .github/workflows/ci.yml
    rm .github/workflows/release.yml
    rmdir .github/workflows > /dev/null 2>&1
    rm .github/settings.yml
    rmdir .github > /dev/null 2>&1
    git rm -f  common-dev-assets
    find . -name .gitmodules -maxdepth 1 -type f -empty -print -delete
    git reset --hard HEAD
elif [[ "$1" == "help" || "$1" == "-h" ]]
then
  echo "This script can be used to migrate the existing repositories to follow the same format as the repository template https://github.com/terraform-ibm-modules/terraform-ibm-module-template"
  echo "Usage:"
  echo "$0         run migration"
  echo "$0 -r      attempt to remove the migration changes"
  echo "$0 -h      show this help message"
else
  validate_prereqs
  check_correct_repo
  download_template
  add_git_settings
  add_git_submodule
  create_symbolic_links
  add_example
  add_tests
  local_init
  clean_up

  echo "----------------------------------------------------------------"
  echo "Migration complete"
  echo "Execute 'pre-commit run --all-files' and resolve all errors before committing"
fi
