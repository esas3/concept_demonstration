# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_commonsense_session',
  :secret      => '2779215bf787ee2e8e1ea7383d62d0cc2f02b000af8d885addf0fc0e4d751c983b45270071da27c33afd153be402f9269b470a1309cb2a5d36af9b363b830162'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
