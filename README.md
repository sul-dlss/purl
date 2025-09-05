[![Build Status](https://github.com/sul-dlss/purl/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/purl/actions/workflows/ruby.yml)

# PURL

PURL service is a URL resolver that translates a reference to a digital object (in the form of a `druid`), into a full content representation of that object as available in public access environment

## Requirements

1. Ruby (3.4 or greater)
2. [bundler](http://bundler.io/) gem

## Installation

Clone the repository

    $ git clone git@github.com:sul-dlss/purl.git

Move into the app and install dependencies

    $ cd purl
    $ bundle install

Start the development server

    $ bin/dev

## Configuring

Configuration is handled through the [RailsConfig](/railsconfig/config) settings.yml files.

## Development

The defaults in `config/settings.yml` should work on a locally run installation.

You can pull data from the stage stacks mount by running the fixture loader:
```shell
bin/rails runner 'FixtureLoader.load("bn208cc3480", machine: "purl-fetcher-stage")'
```

Or you can do this manually:

1. Create a local "stacks" folder in the root of the PURL rails app on your laptop.
2. Create druid tree folders (e.g. `stacks/xk/755/gc/8675`, just like they would be on stacks) and put `cocina` and `public` XML files there.  You can get examples from the `spec/fixtures/stacks` or production Stacks. Note that the `stacks` folder is already in `.gitignore` so any content copied there will not be added to git. An easy solution would be to run `ln -s spec/fixtures/stacks .`.
3. Create a `config/settings.local.yml` file (if you don't have one already) and add the following:

```
stacks:
  root: stacks
```

### Debugging

When the Rails server is run using `bin/dev`, you can start up a debugger session in a separate terminal via:

```shell
rdbg -A
```

To drop into the debugger, add `debugger` statements where needed in the code and have fun navigating the stack in your debugger session terminal.

## Testing

The test suite (with RuboCop style enforcement) will be run with the default rake task (also run on travis)

    $ rake

The specs can be run without RuboCop style enforcement

    $ rake spec

The RuboCop style enforcement can be run without running the tests

    $ rake rubocop

### Update test fixtures

```
kinit
bin/rails update_metadata
```

Then run tests to see if anything needs to be updated.  Commit the changes to the fixtures.

## Deploying

Deployment is handled automatically via Jenkins when a release is published to GitHub.

## Data
Data is stored in a pair-tree structure starting at `/stacks`.  In each pair-tree is a file called `cocina.json` which is the public representation of the current version of the object.  There is also a `meta.json` file that holds information about where this object is released to.  The `meta.json` is not versionable data.  Additionally there is an XML file called `public` which has a representation of the object that was derived from `cocina.json`.

## Search engine indexing

Only items with "PURL sitemap" release tag (in `meta.json`) are included in the sitemap and all other items have a "noindex" meta tag.

Structured metadata in the form of schema.org markup is generated to enhance discoverability of datasets and videos. [More info about schema.org markup](https://docs.google.com/document/d/1BO10k_zSTqqT1YmlCg5oE4tOsGXiqmHzQyb6itZypwo).
