# emoflon-eclipse-build

[![Build Eclipse eMoflon](https://github.com/maxkratz/emoflon-eclipse-build/actions/workflows/ci.yml/badge.svg?event=push)](https://github.com/maxkratz/emoflon-eclipse-build/actions/workflows/ci.yml)

This repository is used to automatically build an Eclipse eMoflon environment.

* Linux
    * *Eclipse eMoflon user* (with eMoflon installed as plugin)
    * *Eclipse eMoflon dev*
* Windows
    * *Eclipse eMoflon user* (with eMoflon installed as plugin)
    * *Eclipse eMoflon dev*


## Runner requirements

In order to run the "Github Actions" pipeline you must ensure that you have at least one properly configured Linux and one Windows runner added to the project.

### Linux

Installed packages:
* `wget`
* `untar`
* `zip`
* `OpenJDK 11.0.13` (may differ, as this is just used to boot-up Eclipse in headless)
* Github Actions runner

### Windows

Installed packages:
* `WSL2` with, e.g., Debian as distribution. You have to install some packages inside it:
    * `wget`
    * `unzip`
    * `zip`
* `AdoptJDK 16.0.2.7-hotspot` (must exactly match or you have to adapt [ci.yml](.github/workflows/ci.yml))
* Github Actions runner
