# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_management_session_uat',
  :secret      => 'babd3e5b7441a266f88bd2c5a3318414e75ea11bc3b78601a8b530d5a13544111995d5cf7ae86b21ac2b51337dbc783f735116304e77fd51e76466fffd755d1e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
