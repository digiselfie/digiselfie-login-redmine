get 'oauth_digiselfie', :to => 'digiselfie_login_oauth#oauth_digiselfie'
get 'digiselfie/oauth2callback', :to => 'digiselfie_login_oauth#oauth_digiselfie_callback', :as => 'oauth_digiselfie_callback'
