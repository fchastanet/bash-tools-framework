# bash-tools2

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

Build status:
[![Workflow executed at each push](https://github.com/fchastanet/bash-tools2/actions/workflows/push_branch.yml/badge.svg?branch=master)](https://github.com/fchastanet/bash-tools2/actions/workflows/push_branch.yml)
[![Project Status](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges)
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-tools2.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-tools2/?ref=repository-badge)
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-tools2.svg/?label=resolved+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-tools2/?ref=repository-badge)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/fchastanet/bash-tools2.svg)](http://isitmaintained.com/project/fchastanet/bash-tools2 'Average time to resolve an issue')
[![Percentage of issues still open](http://isitmaintained.com/badge/open/fchastanet/bash-tools2.svg)](http://isitmaintained.com/project/fchastanet/bash-tools2 'Percentage of issues still open')

<!-- markdownlint-restore -->

- [1. Excerpt](#1-excerpt)
- [2. Development Environment](#2-development-environment)
  - [2.1. Install build dependencies](#21-install-build-dependencies)
  - [2.2. github page](#22-github-page)

## 1. Excerpt

## 2. Development Environment

### 2.1. Install build dependencies

In order to generate bash documentation nad to run unit tests, you have to
launch this command to install some libraries.

```bash
 ./build/installBuildDeps.sh
```

this script will install the following libraries inside `vendor` folder:

- [fchastanet/tomdoc.sh](https://github.com/fchastanet/tomdoc.sh.git)
- [bats-core/bats-core](https://github.com/bats-core/bats-core.git)
- [bats-core/bats-support](https://github.com/bats-core/bats-support.git)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert.git)
- [Flamefire/bats-mock](https://github.com/Flamefire/bats-mock.git)

### 2.2. github page

Launch locally

```bash
sudo apt-get install ruby-dev
sudo gem install bundler
bundle install
bundle exec jekyll serve
```

Navigate to <http://localhost:4000/>
