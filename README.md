# GoCardless OAuth Demo App

A simple demo of using the GoCardless Pro OAuth flow to connect one's GoCardless account to a third-party application.

This app runs on Heroku at <https://gocardless-oauth-demo.herokuapp.com>.

## Running Locally

```bash
  git clone git@github.com:gocardless/oauth-demo.git
  cd oauth-demo
  bundle install
  # Create a `.env` file, and set in it the settings detailed below
  bundle exec rackup
```

Then open [http://localhost:9292/](http://localhost:4567/)

## Configuration

* __GOCARDLESS_CLIENT_ID__: The `client_id` of your GoCardless app
* __GOCARDLESS_CLIENT_SECRET__: The `client_secret` of your GoCardless app
* __GOCARDLESS_CONNECT_URL__: The URL at which the GoCardless OAuth flow is available (most likely `https://connect.gocardless.com`)
* __GOCARDLESS_CONNECT_AUTHORIZE_PATH__: The path to the authorize endpoint (most likely `/oauth/authorize`)
* __GOCARDLESS_CONNECT_ACCESS_TOKEN_PATH__ The path to the authorize endpoint (most likely `/oauth/access_token`)
* __GOCARDLESS_API_URL__: The URL at which the GoCardless Pro API is available (most likely `https://api.gocardless.com`)
* __SESSION_SECRET__: A random string for securing session data
* __REDIRECT_URI__: The redirect URI of your GoCardless app
