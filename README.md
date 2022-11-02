# eMoflon::IBeX Eclipse Build

[![Build Eclipse eMoflon::IBeX](https://github.com/eMoflon/emoflon-ibex-eclipse-build/actions/workflows/ci.yml/badge.svg?branch=main&event=push)](https://github.com/eMoflon/emoflon-ibex-eclipse-build/actions/workflows/ci.yml)

This repository is used to automatically build an Eclipse [eMoflon::IBeX](https://github.com/eMoflon/emoflon-ibex) environment.

| Name                     | OS      | eMoflon installed  | Dark theme installed | Splash image       | Pattern matcher | Additional packages |
|--------------------------|---------|--------------------|----------------------|--------------------|-----------------|---------------------|
| Eclipse eMoflon user     | Linux   | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: | HiPE            | :heavy_check_mark:  |
| Eclipse eMoflon dev      | Linux   |                    | :heavy_check_mark:   | :heavy_check_mark: | HiPE, *)        | :heavy_check_mark:  |
| Eclipse eMoflon user CI  | Linux   | :heavy_check_mark: |                      |                    | HiPE            |                     |
| Eclipse eMoflon dev CI   | Linux   |                    |                      |                    | HiPE, *)        |                     |
| Eclipse eMoflon dev HiPE | Linux   |                    | :heavy_check_mark:   | :heavy_check_mark: | *)              | :heavy_check_mark:  |
| Eclipse eMoflon user     | Windows | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: | HiPE            | :heavy_check_mark:  |
| Eclipse eMoflon dev      | Windows |                    | :heavy_check_mark:   | :heavy_check_mark: | HiPE, *)        | :heavy_check_mark:  |
| Eclipse eMoflon dev HiPE | Windows |                    | :heavy_check_mark:   | :heavy_check_mark: | *)              | :heavy_check_mark:  |
| Eclipse eMoflon user     | macOS   | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: | HiPE            | :heavy_check_mark:  |
| Eclipse eMoflon dev      | macOS   |                    | :heavy_check_mark:   | :heavy_check_mark: | HiPE, *)        | :heavy_check_mark:  |
| Eclipse eMoflon dev HiPE | macOS   |                    | :heavy_check_mark:   | :heavy_check_mark: | *)              | :heavy_check_mark:  |

*) Democles will be installed manually via the [emoflon-dev-workspace](https://github.com/eMoflon/emoflon-ibex#how-to-develop).
Furthermore, all pattern matcher integrations for eMoflon::IBeX (HiPE and Democles) will be installed manually via the [emoflon-ibex-dev-workspace](https://github.com/eMoflon/emoflon-ibex#how-to-develop).

**Additional packages** are installed for every non-CI build.
Currently, the list of additional packages includes:
- [EclEmma](https://www.eclemma.org/)
- [PMD](https://pmd.github.io/latest/index.html)
- [Checkstyle](https://checkstyle.org/eclipse-cs/#!/)
- [SpotBugs](https://spotbugs.github.io/https://spotbugs.github.io/)

Feel free to request others, e.g., via Github issues.


## Usage/Installation

Quick installation using curl and bash:
`$ FOLDER="$HOME/eclipse-apps/emt"; mkdir -p $FOLDER && cd $FOLDER && curl https://raw.githubusercontent.com/eMoflon/emoflon-ibex-eclipse-build/main/emoflon-update.sh | bash -s -- $FOLDER`

### Normal installation

**The latest release can be found [here](https://github.com/eMoflon/emoflon-ibex-eclipse-build/releases/latest).**
Download an archive for the version you are looking for from the release page and extract it.

### Updating

You can use the [update script](./emoflon-update.sh) to update your installation.
Example usage:
`$ ./emoflon-update.sh ~/eclipse-apps/emt`


## Runner requirements

Currently, all actions are run by the cloud-hosted Github runners.
All required packages get installed by the CI confguration while running.

In order to run the "Github Actions" pipeline on selfhosted runners, you must ensure that you have at least one properly configured Linux, one Windows runner, and one macOS runner added to the Github project.

Required packages (at least):
* `curl`
* `wget`
* `tar`
* `zip`
* `AdoptJDK 16.0.2.7-hotspot` (may differ, as this is just used to boot-up Eclipse in headless mode)
* `imagemagick`
* `fonts-liberation`
* Github Actions runner
* WSL2 with, e.g., Debian as distribution (in case the runner is Windows-based)
* `coreutils` on macOS
