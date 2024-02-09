# common-dev-assets
![This repository contains code and assets that are used to support parts of terraform-ibm-modules development processes. It is not specifically designed to be consumed outside the terraform-ibm-modules project - althought it may be source of inspiration](https://img.shields.io/badge/-Internal%20to%20terraform%20ibm%20modules%20Project-lightgrey "This repository contains code and assets that are used to support parts of terraform-ibm-modules development processes. It is not specifically designed to be consumed outside the terraform-ibm-modules project - althought it may be source of inspiration") [![Build Status](https://github.com/terraform-ibm-modules/common-dev-assets/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/common-dev-assets/actions/workflows/ci.yml)

Repo containing common CI assets.

## Local Development Setup
Follow the below steps to get set up with your local development environment in order to contribute to this repo..

### Prereqs
This repo uses multiple pre-commit hooks, however before hooks can run, you need to have the pre-commit package manager
installed. See the following [installation steps](https://pre-commit.com/#install).

### Install dev dependencies:
To set up all necessary tools (including pre-commit hooks), from the root directory of this repo, run the following
command:
```bash
make
```
