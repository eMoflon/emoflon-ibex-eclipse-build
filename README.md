# emoflon-eclipse-build

[![Build Eclipse eMoflon](https://github.com/maxkratz/emoflon-eclipse-build/actions/workflows/ci.yml/badge.svg?branch=main&event=push)](https://github.com/maxkratz/emoflon-eclipse-build/actions/workflows/ci.yml)

This repository is used to automatically build an Eclipse [eMoflon](https://github.com/eMoflon/emoflon-ibex) environment.

| Name                    | OS      | eMoflon installed  | Dark theme installed | Splash image       |
|-------------------------|---------|--------------------|----------------------|--------------------|
| Eclipse eMoflon user    | Linux   | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: |
| Eclipse eMoflon dev     | Linux   |                    | :heavy_check_mark:   | :heavy_check_mark: |
| Eclipse eMoflon user CI | Linux   | :heavy_check_mark: |                      |                    |
| Eclipse eMoflon dev CI  | Linux   |                    |                      |                    |
| Eclipse eMoflon user    | Windows | :heavy_check_mark: | :heavy_check_mark:   | :heavy_check_mark: |
| Eclipse eMoflon dev     | Windows |                    | :heavy_check_mark:   | :heavy_check_mark: |


## Runner requirements

In order to run the "Github Actions" pipeline you must ensure that you have at least one properly configured Linux and one Windows runner added to the Github project.

### Linux

Required packages:
* `wget`
* `(un)tar`
* `zip`
* `OpenJDK 11.0.13` (may differ, as this is just used to boot-up Eclipse in headless mode)
* `imagemagick`
* Github Actions runner

### Windows

Required packages:
* `WSL2` with, e.g., Debian as distribution. You have to install some packages inside it:
    * `wget`
    * `unzip`
    * `zip`
    * `imagemagick`
* `AdoptJDK 16.0.2.7-hotspot` (must exactly match or you have to adapt [ci.yml](.github/workflows/ci.yml))
* Github Actions runner
