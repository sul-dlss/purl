[![Build Status](https://github.com/sul-dlss/purl/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/purl/actions/workflows/ruby.yml)

# PURL

PURL service is a URL resolver that translates a reference to a digital object (in the form of a `druid`), into a full content representation of that object as available in public access environment

## Requirements

1. Ruby (3.2 or greater)
2. [bundler](http://bundler.io/) gem

## Installation

Clone the repository

    $ git clone git@github.com:sul-dlss/purl.git

Move into the app and install dependencies

    $ cd purl
    $ bundle install
    $ yarn

Start the development server

    $ bin/dev

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

Deployment is handled automatically via Jenkins when a release is published to GitHub.

## Analytics

Analytics are collected via both Google Analytics and [ahoy](https://github.com/ankane/ahoy).

When in local development, you may find it useful to fake analytics events as though they had been triggered by sul-embed. If `analytics_debug` is set to `true` in your Rails config, the [ahoy.js](https://github.com/ankane/ahoy.js) library will be loaded onto each page.

You can then trigger analytics events by calling `ahoy.track` in the browser console. For example:
```js
ahoy.trackView({ druid: "abc123" });
```

To trigger a download event:
```js
ahoy.track("download", { druid: "abc123" });
```

The `druid` parameter is required to associate the events with a particular `PurlResource` object.
