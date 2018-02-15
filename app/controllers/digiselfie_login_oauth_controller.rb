require 'account_controller'
require 'json'

class DigiselfieLoginOauthController < AccountController
  include Helpers::DigiselfieLoginMailHelper
  def oauth_digiselfie
    if Setting.plugin_digiselfie_login['oauth_authentification']
      session[:back_url] = params[:back_url]
      redirect_to oauth_client.auth_code.authorize_url(:redirect_uri => oauth_digiselfie_callback_url, :state => state_shuffle, :prompt => prompt, :scope => scopes)
    else
      password_authentication
    end
  end

  def oauth_digiselfie_callback
    if params[:error]
      flash[:error] = l(:notice_digiselfie_access_denied)
      redirect_to signin_path
    else

      params[:grant_type] = 'authorization_code'
      params[:client_id] = settings['client_id']
      params[:client_secret] = settings['client_secret']

      # print params.inspect

      result = oauth_client.request(:get, $config['digiselfie']['claim_url'], {:params => params, :headers => {'Authorization' => 'Bearer ' + params[:code]}} )

      # print result.inspect

      info = JSON.parse(result.body)

      # print "info"
      # print info.inspect

      if info && info["Id"]
          try_to_login info
      else
        flash[:error] = l(:notice_unable_to_obtain_digiselfie_credentials)
        redirect_to signin_path
      end
    end
  end

  def try_to_login info
   params[:back_url] = session[:back_url]
   session.delete(:back_url)

  if info["Emails"].present?
    usrmailobj = info["Emails"].first
    user_mail = usrmailobj["Address"]
  end

  user = User.joins(:email_addresses).where(:email_addresses => { :address => user_mail }).first_or_create
    if user.new_record?
      # Self-registration off
      redirect_to(home_url) && return unless Setting.self_registration?
      # Create on the fly
      user.firstname = info["FirstName"]
      user.lastname = info["LastName"]

      if info["Emails"].present?
        user.mail = usrmailobj["Address"]
        user.login = parse_email(user.mail)[:login]
      else
        user.login =  user.firstname.downcase + '_' + user.lastname.downcase
      end

      i = 0
      while User.exists?(login: user.login) do
        i+=1
        user.login = "#{user.login}_#{i}"
      end

      user.random_password
      user.register

      case Setting.self_registration
      when '1'
        register_by_email_activation(user) do
          onthefly_creation_failed(user)
        end
      when '3'
        register_automatically(user) do
          onthefly_creation_failed(user)
        end
      else
        register_manually_by_administrator(user) do
          onthefly_creation_failed(user)
        end
      end
    else
      # Existing record
      if user.active?
        successful_authentication(user)
      else
        # Redmine 2.4 adds an argument to account_pending
        if Redmine::VERSION::MAJOR > 2 or
          (Redmine::VERSION::MAJOR == 2 and Redmine::VERSION::MINOR >= 4)
          account_pending(user)
        else
          account_pending
        end
      end
    end
  end

  def prompt
    'consent'
  end

  def state_shuffle
    @state = params[:token]
    # @state ||= "HA-" + "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".split("").shuffle.join
  end

  def oauth_client
    @client ||= OAuth2::Client.new(settings['client_id'], settings['client_secret'],
      :site => $config['digiselfie']['site'],
      :authorize_url => $config['digiselfie']['authorize_url'],
      :token_url => $config['digiselfie']['token_url']
    )
  end

  def settings
    @settings ||= Setting.plugin_digiselfie_login
  end

  def scopes
    'offline openid'
  end

  def tokenheader
    'Basic ' + Base64.encode64(settings['client_id'] + ':' + settings['client_secret'])
  end

end
