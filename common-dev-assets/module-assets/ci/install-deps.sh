#!/bin/bash

set -o errexit
set -o pipefail

# Place binaries in /usr/local/bin unless $CUSTOM_DIRECTORY defined
if [[ -z "${CUSTOM_DIRECTORY}" ]]; then
  DIRECTORY="/usr/local/bin"
else
  DIRECTORY="${CUSTOM_DIRECTORY}"
  mkdir -p "${DIRECTORY}"
fi

# Optionally specify the directory to run tfswitch in. If not speciffied it will run in repo root dir
if [[ -z "${TFSWITCH_DIRECTORY}" ]]; then
  TFSWITCH_DIR="."
else
  TFSWITCH_DIR="${TFSWITCH_DIRECTORY}"
fi

# Determine OS type
if [[ $OSTYPE == 'darwin'* ]]; then
  OS="darwin"
else
  OS="linux"
fi

# Function to download files
function download {

  binary=$1
  version=$2
  url=$3
  file=$4
  sumfile=$5
  tmp_dir=$6

  echo "Downloading ${binary} ${version}..."
  curl --retry 3 -fLsS "${url}/${file}" --output "${tmp_dir}/${file}"

  if [ "${sumfile}" != "" ]; then
    curl --retry 3 -fLsS "${url}/${sumfile}" --output "${tmp_dir}/${sumfile}"
  else
    echo "No checksum file passed, skipping verification."
  fi

}

# Function to verify checksum of download file
function verify {

  file=$1
  sumfile=$2
  tmp_dir=$3

  echo "Verifying.."
  checksum=$(< "${tmp_dir}/${sumfile}" grep "${file}" | awk '{ print $1 }')
  echo "${checksum} ${tmp_dir}/${file}" | sha256sum -c

}

# Function to verify checksum of download file (when binary name not in sumfile)
function verify_alternative {

  file=$1
  sumfile=$2
  tmp_dir=$3

  echo "Verifying.."
  checksum=$(cat "${tmp_dir}/${sumfile}")
  echo "${checksum} ${tmp_dir}/${file}" | sha256sum -c

}

# Function to copy and replace binary in $DIRECTORY
function copy_replace_binary {

  binary=$1
  tmp_dir=$2

  echo "Placing ${binary} binary in ${DIRECTORY} and making executable.."
  arg=""
  if ! [ -w "${DIRECTORY}" ]; then
    echo "No write permission to ${DIRECTORY}. Attempting to run with sudo..."
    arg=sudo
  fi
  # Need to delete if exists already in case it is a symlink which cannot be overwritten using cp -r
  ${arg} rm -f "${DIRECTORY}/${binary}"
  ${arg} cp -r "${tmp_dir}/${binary}" "${DIRECTORY}"
  ${arg} chmod +x "${DIRECTORY}/${binary}"

}

# Cleanup function
function clean {

  tmp_dir=$1

  echo "Deleting tmp dir: ${tmp_dir}"
  rm -rf "${tmp_dir}"
  echo "COMPLETE"
  echo
}

#######################################
# sha256sum
#######################################

if ! sha256sum --version &> /dev/null; then
  # If sha256sum not detected on mac, install coreutils
  if [ "$OS" == "darwin" ]; then
    echo
    echo "-- Installing coreutils..."
    brew install coreutils
  else
    echo "sha256sum must be installed to verify downloads. Please install and retry."
    exit 1
  fi
fi

#######################################
# python
#######################################

if python3 --version &> /dev/null; then
  PYTHON=python3
elif python --version &> /dev/null; then
  PYTHON=python3
else
  echo "python or python3 not detected. Please install python, ensure it is on your \$PATH, and retry."
  exit 1
fi

#######################################
# pip
#######################################

if ! ${PYTHON} -m pip &> /dev/null; then
  echo "Unable to detect pip after running: ${PYTHON} -m pip. Please ensure pip is installed and try again."
  exit 1
fi

#######################################
# pre-commit
#######################################

 # renovate: datasource=github-tags depName=pre-commit/pre-commit
PRE_COMMIT_VERSION=v3.6.0
PACKAGE=pre-commit
set +e
INSTALLED_PRE_COMMIT_VERSION="$(${PYTHON} -m pip show pre-commit | grep Version: | cut -d' ' -f2)"
set -e
if [[ "$PRE_COMMIT_VERSION" != "v$INSTALLED_PRE_COMMIT_VERSION" ]]; then

  echo
  echo "-- Installing ${PACKAGE} ${PRE_COMMIT_VERSION}..."

  ${PYTHON} -m pip install -q --upgrade ${PACKAGE}==${PRE_COMMIT_VERSION}
  echo "COMPLETE"
else
 echo "${PACKAGE} ${PRE_COMMIT_VERSION} already installed - skipping install"
fi

#######################################
# detect-secrets
#######################################

 # renovate: datasource=github-tags depName=ibm/detect-secrets versioning="regex:^(?<compatibility>.*)-?(?<major>\\d+)\\.(?<minor>\\d+)\\+ibm\\.(?<patch>\\d+)\\.dss$"
DETECT_SECRETS_VERSION=0.13.1+ibm.62.dss
PACKAGE=detect-secrets
set +e
INSTALLED_DECTECT_SECRETS="$(${PYTHON} -m pip show detect-secrets | grep Version: | cut -d' ' -f2)"
set -e
if [[ "$DETECT_SECRETS_VERSION" != "$INSTALLED_DECTECT_SECRETS" ]]; then

  echo
  echo "-- Installing ${PACKAGE} ${DETECT_SECRETS_VERSION}..."

  ${PYTHON} -m pip install -q --upgrade "git+https://github.com/ibm/detect-secrets.git@${DETECT_SECRETS_VERSION}#egg=detect-secrets"
  echo "COMPLETE"
else
 echo "${PACKAGE} ${DETECT_SECRETS_VERSION} already installed - skipping install"
fi

#######################################
# terraform-switcher
#######################################

 # renovate: datasource=github-releases depName=warrensbox/terraform-switcher
TFSWITCH_VERSION=0.13.1308
BINARY=tfswitch
set +e
INSTALLED_TFSWITCH_VERSION="$(tfswitch --version | grep Version | awk '{ print $2 }')"
set -e
if [[ "$TFSWITCH_VERSION" != "$INSTALLED_TFSWITCH_VERSION" ]]; then
  FILE_NAME="terraform-switcher_${TFSWITCH_VERSION}_${OS}_amd64.tar.gz"
  URL="https://github.com/warrensbox/terraform-switcher/releases/download/${TFSWITCH_VERSION}"
  SUMFILE="terraform-switcher_${TFSWITCH_VERSION}_checksums.txt"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${TFSWITCH_VERSION}..."

  download ${BINARY} "${TFSWITCH_VERSION}" "${URL}" "${FILE_NAME}" "${SUMFILE}" "${TMP_DIR}"
  verify "${FILE_NAME}" "${SUMFILE}" "${TMP_DIR}"
  tar -xzf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${TFSWITCH_VERSION} already installed - skipping install"
fi

#######################################
# terraform
#######################################

# Locking into last version that is not BSL
TERRAFORM_VERSION=v1.5.7
BINARY=terraform

TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)
echo
echo "-- Installing terraform ..."

# Remove if binary already exists in /usr/local/bin
arg=""
if ! [ -w "${DIRECTORY}" ]; then
  echo "No write permission to ${DIRECTORY}. Attempting to run with sudo..."
  arg=sudo
fi
${arg} rm -f "${DIRECTORY}/${BINARY}"

# If a .tf file with the terraform constrain is detected in the current directory, it should automatically download or switch to the latest terraform version in the defined range.
# Otherwise it will default to TERRAFORM_VERSION value defined above
tfswitch --default "${TERRAFORM_VERSION:1}" --bin "${TMP_DIR}/${BINARY}" --chdir "${TFSWITCH_DIR}"
actual_binary_location=$(which "${TMP_DIR}/${BINARY}")
copy_replace_binary ${BINARY} "$(dirname "${actual_binary_location}")"
clean "${TMP_DIR}"

#######################################
# terragrunt
#######################################

 # renovate: datasource=github-releases depName=gruntwork-io/terragrunt
TERRAGRUNT_VERSION=v0.55.0
BINARY=terragrunt
set +e
INSTALLED_TERRAGRUNT_VERSION="$(terragrunt --version | head -1 | cut -d' ' -f3)"
set -e
if [[ "$TERRAGRUNT_VERSION" != "$INSTALLED_TERRAGRUNT_VERSION" ]]; then
  FILE_NAME="terragrunt_${OS}_amd64"
  URL="https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}"
  SUMFILE=SHA256SUMS
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${TERRAGRUNT_VERSION}..."

  download ${BINARY} ${TERRAGRUNT_VERSION} ${URL} ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  verify ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  # rename binary to terragrunt
  mv "${TMP_DIR}/${FILE_NAME}" "${TMP_DIR}/${BINARY}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${TERRAGRUNT_VERSION} already installed - skipping install"
fi
#######################################
# terraform-docs
#######################################

 # renovate: datasource=github-releases depName=terraform-docs/terraform-docs
TERRAFORM_DOCS_VERSION=v0.17.0
BINARY=terraform-docs
set +e
INSTALLED_TERRADOCS_VERSION="$(terraform-docs --version | head -1 | cut -d' ' -f3)"
set -e
if [[ "$TERRAFORM_DOCS_VERSION" != "$INSTALLED_TERRADOCS_VERSION" ]]; then
  FILE_NAME="terraform-docs-${TERRAFORM_DOCS_VERSION}-${OS}-amd64.tar.gz"
  URL="https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}"
  SUMFILE="terraform-docs-${TERRAFORM_DOCS_VERSION}.sha256sum"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${TERRAFORM_DOCS_VERSION}..."

  download ${BINARY} ${TERRAFORM_DOCS_VERSION} ${URL} ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  verify ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  tar -xzf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${TERRAFORM_DOCS_VERSION} already installed - skipping install"
fi

#######################################
# tflint
#######################################
 # renovate: datasource=github-releases depName=terraform-linters/tflint
TFLINT_VERSION=v0.50.2
BINARY=tflint
set +e
INSTALLED_TFLINT_VERSION="$(tflint --version | grep "TFLint version " |cut -d' ' -f3)"
set -e
if [[ "$TFLINT_VERSION" != "v$INSTALLED_TFLINT_VERSION" ]]; then
  FILE_NAME="tflint_${OS}_amd64.zip"
  URL="https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}"
  SUMFILE="checksums.txt"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${TFLINT_VERSION}..."

  download ${BINARY} ${TFLINT_VERSION} ${URL} ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  verify ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  unzip "${TMP_DIR}/${FILE_NAME}" -d "${TMP_DIR}" > /dev/null
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${TFLINT_VERSION} already installed - skipping install"
fi

#######################################
# tfsec
#######################################

 # renovate: datasource=github-releases depName=aquasecurity/tfsec
TFSEC_VERSION=v1.28.5
BINARY=tfsec
set +e
INSTALLED_TFSEC_VERSION="$(tfsec --version)"
set -e
if [[ "$TFSEC_VERSION" != "$INSTALLED_TFSEC_VERSION" ]]; then
  FILE_NAME="tfsec-${OS}-amd64"
  URL="https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}"
  SUMFILE="tfsec_checksums.txt"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${TFSEC_VERSION}..."

  download ${BINARY} ${TFSEC_VERSION} ${URL} ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  verify ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  # rename binary to tfsec
  mv "${TMP_DIR}/${FILE_NAME}" "${TMP_DIR}/${BINARY}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${TFSEC_VERSION} already installed - skipping install"
fi

#######################################
# golangci-lint
#######################################

 # renovate: datasource=github-releases depName=golangci/golangci-lint
GOLANGCI_LINT_VERSION=v1.55.2
BINARY=golangci-lint
set +e
INSTALLED_GOLANGCI_LINT_VERSION="$(golangci-lint --version | head -1 | cut -d' ' -f4)"
set -e
if [[ "$GOLANGCI_LINT_VERSION" != "v$INSTALLED_GOLANGCI_LINT_VERSION" ]]; then
  FILE_NAME="golangci-lint-${GOLANGCI_LINT_VERSION//v/}-${OS}-amd64.tar.gz"
  URL="https://github.com/golangci/golangci-lint/releases/download/${GOLANGCI_LINT_VERSION}"
  SUMFILE="${BINARY}-${GOLANGCI_LINT_VERSION//v/}-checksums.txt"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${GOLANGCI_LINT_VERSION}..."

  download ${BINARY} ${GOLANGCI_LINT_VERSION} ${URL} "${FILE_NAME}" "${SUMFILE}" "${TMP_DIR}"
  verify "${FILE_NAME}" "${SUMFILE}" "${TMP_DIR}"
  tar -xzf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}/golangci-lint-${GOLANGCI_LINT_VERSION//v/}-${OS}-amd64"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${GOLANGCI_LINT_VERSION} already installed - skipping install"
fi

#######################################
# Shellcheck
#######################################

 # renovate: datasource=github-releases depName=koalaman/shellcheck
SHELLCHECK_VERSION=v0.9.0
BINARY=shellcheck
set +e
INSTALLED_SHELLCHECK_VERSION="$(shellcheck --version | grep "version:" | cut -d' ' -f2)"
set -e
if [[ "$SHELLCHECK_VERSION" != "v$INSTALLED_SHELLCHECK_VERSION" ]]; then
  FILE_NAME="shellcheck-${SHELLCHECK_VERSION}.${OS}.x86_64.tar.xz"
  URL="https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}"
  SUMFILE=""
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${SHELLCHECK_VERSION}..."

  download ${BINARY} ${SHELLCHECK_VERSION} ${URL} ${FILE_NAME} "${SUMFILE}" "${TMP_DIR}"
  tar -xf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}/${BINARY}-${SHELLCHECK_VERSION}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${SHELLCHECK_VERSION} already installed - skipping install"
fi

#######################################
# hadolint
#######################################

 # renovate: datasource=github-releases depName=hadolint/hadolint
HADOLINT_VERSION=v2.12.0
BINARY=hadolint
set +e
INSTALLED_HADOLINT_VERSION="$(hadolint --version | head -1 | cut -d' ' -f4)"
set -e
if [[ "$HADOLINT_VERSION" != "v$INSTALLED_HADOLINT_VERSION" ]]; then
  FILE_NAME="hadolint-${OS}-x86_64"
  URL="https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}"
  SUMFILE=""
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${HADOLINT_VERSION}..."

  download ${BINARY} ${HADOLINT_VERSION} ${URL} ${FILE_NAME} "${SUMFILE}" "${TMP_DIR}"
  ## rename binary to hadolint
  mv "${TMP_DIR}/${FILE_NAME}" "${TMP_DIR}/${BINARY}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${HADOLINT_VERSION} already installed - skipping install"
fi

#######################################
# helm
#######################################

 # renovate: datasource=github-releases depName=helm/helm
HELM_VERSION=v3.14.0
BINARY=helm
set +e
INSTALLED_HELM_VERSION="$(helm version | cut -d':' -f2 | cut -d'"' -f2)"
set -e
if [[ "$HELM_VERSION" != "$INSTALLED_HELM_VERSION" ]]; then
  FILE_NAME="helm-${HELM_VERSION}-${OS}-amd64.tar.gz"
  URL="https://get.helm.sh"
  SUMFILE="helm-${HELM_VERSION}-${OS}-amd64.tar.gz.sha256"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${HELM_VERSION}..."

  download ${BINARY} ${HELM_VERSION} ${URL} ${FILE_NAME} "${SUMFILE}" "${TMP_DIR}"
  verify_alternative ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  tar -xzf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}/${OS}-amd64"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${HELM_VERSION} already installed - skipping install"
fi
#######################################
# kubectl
#######################################

 # renovate: datasource=github-releases depName=kubernetes/kubernetes
KUBECTL_VERSION=v1.29.1
BINARY=kubectl
set +e
INSTALLED_KUBECTL_VERSION="$(kubectl version --output yaml --client | grep "gitVersion" | cut -d' ' -f4)"
set -e
if [[ "$KUBECTL_VERSION" != "$INSTALLED_KUBECTL_VERSION" ]]; then
  FILE_NAME="kubectl"
  URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS}/amd64"
  SUMFILE="kubectl.sha256"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${KUBECTL_VERSION}..."

  download ${BINARY} ${KUBECTL_VERSION} ${URL} ${FILE_NAME} "${SUMFILE}" "${TMP_DIR}"
  verify_alternative ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${KUBECTL_VERSION} already installed - skipping install"
fi

#######################################
# oc
#######################################

OC_OS=${OS}
if [[ $OSTYPE == 'darwin'* ]]; then
  OC_OS="mac"
fi

# OC cli version must be maintained manually, as there is no supported renovate datasource to find newer versions.
OC_VERSION=4.11.9
BINARY=oc
set +e
INSTALLED_OC_VERSION="$(oc version --client | grep "Client Version:" | cut -d' ' -f3)"
set -e
if [[ "$OC_VERSION" != "$INSTALLED_OC_VERSION" ]]; then
  FILE_NAME="openshift-client-${OC_OS}-${OC_VERSION}.tar.gz"
  URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}"
  SUMFILE="sha256sum.txt"
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${OC_VERSION}..."

  download ${BINARY} ${OC_VERSION} ${URL} ${FILE_NAME} "${SUMFILE}" "${TMP_DIR}"
  verify ${FILE_NAME} ${SUMFILE} "${TMP_DIR}"
  tar -xzf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} cli ${OC_VERSION} already installed - skipping install"
fi

#######################################
# jq
#######################################

JQ_OS=${OS}
if [[ $OSTYPE == 'darwin'* ]]; then
  JQ_OS="osx-amd"
fi

 # renovate: datasource=github-releases depName=stedolan/jq
JQ_VERSION=1.6
BINARY=jq
set +e
INSTALLED_JQ_VERSION="$(jq --version | cut -c4-)"
set -e
if [[ "$JQ_VERSION" != "$INSTALLED_JQ_VERSION" ]]; then
  FILE_NAME="jq-${JQ_OS}64"
  URL="https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}"
  SUMFILE=""
  TMP_DIR=$(mktemp -d /tmp/${BINARY}-XXXXX)

  echo
  echo "-- Installing ${BINARY} ${JQ_VERSION}..."

  download ${BINARY} ${JQ_VERSION} ${URL} ${FILE_NAME} "${SUMFILE}" "${TMP_DIR}"
  # rename binary to jq
  mv "${TMP_DIR}/${FILE_NAME}" "${TMP_DIR}/${BINARY}"
  copy_replace_binary ${BINARY} "${TMP_DIR}"
  clean "${TMP_DIR}"
else
  echo "${BINARY} ${JQ_VERSION} already installed - skipping install"
fi
