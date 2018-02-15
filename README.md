## Redmine omniauth digiselfie

DigiSelfie Login allows your website visitors and customers to register on using their existing DigiSelfie account ID, eliminating the need to fill out registration forms and remember usernames and passwords.

### Installation:

Download the plugin, upload it to plugins directory and install required gems:

```console
bundle install
```

Restart the app
```console
touch /path/to/redmine/tmp/restart.txt
```

### Registration

To authenticate via Digiselfie follow the steps  :

* First go to: https://www.digiselfie.com
* Create a new application.
* Fill out any required fields such as the application name and description.
* Provide this URL as the Callback URL for your application
* Once you have registered, past the created application credentials into the boxes above.

Additionaly
* Setup value Autologin in Settings on tab Authentication
