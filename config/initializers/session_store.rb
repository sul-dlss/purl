# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_purl_session',
  :secret      => '3ba1eea539893d61319e43573388c3b0de8767cbe4668a76bd741c3c44832270021fe4d41b976a5cc98e6a790ce93b59ba658eb393bbb0c0310eaab0c9acb56a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
