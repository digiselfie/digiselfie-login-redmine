require 'redmine'
require_dependency 'digiselfie_login/hooks'

Redmine::Plugin.register :digiselfie_login do
  name 'Digiselfie Login plugin'
  author 'Digital Selfie, Inc'
  description 'Digiselfie login plugin for Redmine'
  version '0.0.1'
  author_url 'https://www.digiselfie.com/'

  settings :default => {
    :client_id => "",
    :client_secret => "",
    :oauth_autentification => false,
    :digiselfie_api_key => "",
  },:partial => 'settings/digiselfie_login_settings'

  $config = YAML::load(File.open("#{File.dirname(__FILE__)}/config/config.yml"))
end
