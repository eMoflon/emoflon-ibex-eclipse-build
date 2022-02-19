# emoflon-eclipse-build

[![Build Eclipse eMoflon](https://github.com/maxkratz/emoflon-eclipse-build/actions/workflows/ci.yml/badge.svg?branch=main&event=push)](https://github.com/maxkratz/emoflon-eclipse-build/actions/workflows/ci.yml)

This repository is used to automatically build an Eclipse [eMoflon](https://github.com/eMoflon/emoflon-ibex) environment.

| Name                    | OS      | eMoflon installed  | Dark theme installed | Splash image       | Pattern matcher |
|-------------------------|---------|--------------------|----------------------|--------------------|-----------------|
| Eclipse eMoflon user    | Linux   | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: | HiPE            |
| Eclipse eMoflon dev     | Linux   |                    | :heavy_check_mark:   | :heavy_check_mark: | HiPE, *)        |
| Eclipse eMoflon user CI | Linux   | :heavy_check_mark: |                      |                    | HiPE            |
| Eclipse eMoflon dev CI  | Linux   |                    |                      |                    | HiPE, *)        |
| Eclipse eMoflon user    | Windows | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: | HiPE            |
| Eclipse eMoflon dev     | Windows |                    | :heavy_check_mark:   | :heavy_check_mark: | HiPE, *)        |

*) Democles will be installed manually via the [emoflon-dev-workspace](https://github.com/eMoflon/emoflon-ibex#how-to-develop).
Furthermore, all pattern matcher integrations for eMoflon (HiPE and Democles) will be installed manually via the [emoflon-dev-workspace](https://github.com/eMoflon/emoflon-ibex#how-to-develop).


## Runner requirements

In order to run the "Github Actions" pipeline you must ensure that you have at least one properly configured Linux and one Windows runner added to the Github project.

### Linux

Required packages:
* `curl`
* `wget`
* `(un)tar`
* `zip`
* `OpenJDK 11.0.13` (may differ, as this is just used to boot-up Eclipse in headless mode)
* `imagemagick`
* Github Actions runner

### Windows

Required packages:
* `WSL2` with, e.g., Debian as distribution. You have to install some packages inside it:
    * `curl`
    * `wget`
    * `unzip`
    * `zip`
    * `imagemagick`
* `AdoptJDK 16.0.2.7-hotspot` (must exactly match or you have to adapt [ci.yml](.github/workflows/ci.yml))
* Github Actions runner

### Github secrets

To remove hardcoded values from the CI config ([ci.yml](.github/workflows/ci.yml))), this project uses [Github secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

| Name                    | Example value                                                | Used for                          |
|-------------------------|--------------------------------------------------------------|-----------------------------------|
| WINDOWS_JDK_BIN_PATH    | C:\Program Files\Eclipse Foundation\jdk-16.0.2.7-hotspot\bin | JDK path config (Windows runners) |
