# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_docs_session',
  :secret      => '767fc3c7faf1818e180ce331c0cb59313f4de8256f6554a175e01a329117f55e7e072cbf5aad8d75b59c22a3a9abf8606aa28499fad0de618b69df508ea3d5f2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
