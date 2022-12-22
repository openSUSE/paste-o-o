Hi,
Welcome to the contributing guide for the paste.opensuse.org website. We are very eager to take any and all contributions from you, and to aid you in successfully contributing to this codebase.

* [About](#about)
  * [Where is the code hosted?](#where-is-the-code-hosted)
  * [What are the technologies used?](#what-are-the-technologies-used)
  * [Get in contact with us!](#get-in-contact-with-us)
  * [Submitting changes](#submitting-changes)
* [Reporting Bugs](#reporting-bugs)
  * [Fixing Bugs](#fixing-bugs)
* [Setting up the development environment](#setting-up-the-development-environment)
* [Running tests](#running-tests)

# About

## Where is the code hosted?
You can find the canonical git repository here: <https://github.com/openSUSE/paste-o-o.git>

## What are the technologies used?
This is a [Ruby on Rails](https://rubyonrails.org/) based website, using the [openSUSE theme](https://github.com/openSUSE/chameleon/).

## Get in contact with us!
We are available on various instant messaging platforms, as well as more traditional mailing list, use the links below to get in contact if you need or want to.

* Matrix: <https://matrix.to/#/#web:opensuse.org>
* Discord: <https://discord.gg/openSUSE>
* Mailing Lists: <https://lists.opensuse.org/archives/list/web@lists.opensuse.org/>

## Submitting changes
To submit changes for review, create a pull request on the [site's GitHub](https://github.com/openSUSE/paste-o-o/), if your PR contains UI changes, please include a screenshot before and after, so that it's easier for us to review the changes.

# Reporting Bugs
Bugs in this repo need to be reported to the GitHub Issues on the GitHub repo.
You can do so here: https://github.com/openSUSE/paste-o-o/issues/new

## Fixing Bugs
The link below lists all the currently reported bugs against the project on GitHub.
https://github.com/openSUSE/paste-o-o/issues
Those bugs still need fixing and we would appreciate any pull requests fixing them.

# Setting up the development environment
You will need to install `git` and `docker-compose` first, then run:

```sh
git clone https://github.com/openSUSE/paste-o-o.git
cd paste-o-o
cp config/database.sample.yml config/database.yml
cp config/site.sample.yml config/site.yml
cp config/storage.sample.yml config/storage.yml
docker-compose build
docker-compose run web bin/rails db:create
docker-compose run web bin/rails db:migrate RAILS_ENV=development
docker-compose up
```
and visit <http://127.0.0.1:3000/> to see the website running in your browser

# Running tests
After making changes to the codebase, you may want to run some of the tests included to make sure your changes didn't break any other feature.

```sh
docker-compose run --rm web bundler exec rubocop
docker-compose run --rm web bundler exec rspec
```

## Thank you for considering contributing!

