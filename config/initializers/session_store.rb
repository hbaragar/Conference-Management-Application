# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_management_session',
  :secret      => 'b2b4ca55370c2453f638e826bd1a2d4b90a2fb69f8eee6338a61426f6bfaa1cddca0ddf72780a0d0085b52d7717c4574335258fe04c50ea988a06804221966ce'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
