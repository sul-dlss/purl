[![Build Status](https://travis-ci.org/sul-dlss/purl.svg?branch=master)](https://travis-ci.org/sul-dlss/purl)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/purl/badge.svg?branch=master)](https://coveralls.io/github/sul-dlss/purl?branch=master)
[![Code Climate](https://codeclimate.com/github/sul-dlss/purl/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/purl)
[![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/purl/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/purl/coverage)
[![GitHub version](https://badge.fury.io/gh/sul-dlss%2Fpurl.svg)](https://badge.fury.io/gh/sul-dlss%2Fpurl)

# PURL

PURL service is a URL resolver that translates a reference to a digital object (in the form of a `druid`), into a full content representation of that object as available in public access environment


Please create a github release before deploying.

## Requirements

1. Ruby (2.2.5 or greater)
2. [bundler](http://bundler.io/) gem

## Installation

Clone the repository

    $ git clone git@github.com:sul-dlss/purl.git

Move into the app and install dependencies

    $ cd purl
    $ bundle install

Start the development server

    $ rails s

## Configuring

Configuration is handled through the [RailsConfig](/railsconfig/config) settings.yml files.

#### Local Configuration

The defaults in `config/settings.yml` should work on a locally run installation.

## Testing

The test suite (with RuboCop style enforcement) will be run with the default rake task (also run on travis)

    $ rake

The specs can be run without RuboCop style enforcement

    $ rake spec

The RuboCop style enforcement can be run without running the tests

    $ rake rubocop

## Deploying

Please create a github release before deploying to production.

Capistrano is used for deployment

    $ cap dev deploy
