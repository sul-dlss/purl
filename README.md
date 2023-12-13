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

Start the development server

    $ bin/dev

## Configuring

Configuration is handled through the [RailsConfig](/railsconfig/config) settings.yml files.

#### Local Configuration

The defaults in `config/settings.yml` should work on a locally run installation.

By default, local development will use production XML from PURL, so that you can hit any valid object when testing locally.  If you want to use local XML for testing, which can be useful if you want to alter data and see the results, do this:

1. Create a local "document_cache" folder in the root of the PURL rails app on your laptop.
2. Create druid tree folders (e.g. `document_cache/xk/755/gc/8675`, just like they would be on stacks) and put `mods` and `public` XML files there.  You can get examples from the `spec/fixtures/document_cache` or production PURL.  Note that the `document_cache` folder is already in `.gitignore` so any content copied there will not be added to git.
3. Create a `config/settings.local.yml` file (if you don't have one already) and add the following:

```
# Comment out for lookup to production PURL
purl_resource:
  mods: "<%= File.join(Rails.root, "document_cache") %>/%{druid_tree}/mods"
  public_xml: "<%= File.join(Rails.root, "document_cache") %>/%{druid_tree}/public"
  cocina: "<%= File.join(Rails.root, "document_cache") %>/%{druid_tree}/cocina.json"
```

If you leave this config uncommented, the local app will find content in the local document_cache.  If you comment it out, it will revert to the default behavior (look up content on PURL).

## Testing

The test suite (with RuboCop style enforcement) will be run with the default rake task (also run on travis)

    $ rake

The specs can be run without RuboCop style enforcement

    $ rake spec

The RuboCop style enforcement can be run without running the tests

    $ rake rubocop

## Deploying

Deployment is handled automatically via Jenkins when a release is published to GitHub.

## Search engine indexing

The current policy is to only index items that [belong to configured collections or have a specified source id prefix](https://github.com/sul-dlss/purl/blob/c4f38e4dfa40a301603fe73f51dbba8e53c901d2/app/models/purl_resource.rb#L92). Only those items are included in the sitemap and all other items have a "noindex" meta tag.

Structured metadata in the form of schema.org markup is generated to enhance discoverability of datasets and videos. [More info about schema.org markup](https://docs.google.com/document/d/1BO10k_zSTqqT1YmlCg5oE4tOsGXiqmHzQyb6itZypwo). 
