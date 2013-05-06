# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# FEDORA_URL = 'https://dor-test.stanford.edu/fedora'
# FEDORA_URL = 'http://localhost:8983/fedora'
module Dor
  WF_URI = 'http://lyberservices-test.stanford.edu/workflow'
end

FEDORA_URL = 'https://fedoraAdmin:fedoraAdmin@dor-test.stanford.edu/fedora'
CERT_FILE = File.join(RAILS_ROOT, "config", "certs", "ls-test.crt")
KEY_FILE = File.join(RAILS_ROOT, "config", "certs", "ls-test.key")
KEY_PASS = 'lstest'

STACKS_URL = 'http://stacks-test.stanford.edu'
FLIPBOOK_URL = 'http://sul-reader.stanford.edu/flipbook2-test'

# document cache location
DOCUMENT_CACHE_ROOT = '/home/lyberadmin/document_cache'