# GoCardless OAuth Demo App

A simple demo of using the GoCardless Pro [OAuth API](https://developer.gocardless.com/pro/2015-07-06/#guides-oauth) to connect one's GoCardless account to a third-party application.

A public instance of this app for use as a demo runs on Heroku at <https://gocardless-oauth-demo.herokuapp.com>.

## Running Locally

```bash
  git clone https://github.com/gocardless/oauth-demo.git
  cd oauth-demo
  bundle
  cp .env.example .env
  $EDITOR .env
  # Update the .env file wih your authentication details (see below for help)
  bundle exec rackup
```

Then open [http://localhost:9292/](http://localhost:9292/)

## Configuration

* __GOCARDLESS_CLIENT_ID__: The `client_id` of your GoCardless app
* __GOCARDLESS_CLIENT_SECRET__: The `client_secret` of your GoCardless app
* __GOCARDLESS_CONNECT_URL__: The URL at which the GoCardless OAuth flow is available (`https://connect.gocardless.com` or `https://connect-sandbox.gocardless.com`)
* __GOCARDLESS_CONNECT_AUTHORIZE_PATH__: The path to the authorize endpoint (`/oauth/authorize`)
* __GOCARDLESS_CONNECT_ACCESS_TOKEN_PATH__ The path to the authorize endpoint (`/oauth/access_token`)
* __GOCARDLESS_API_URL__: The URL at which the GoCardless Pro API is available (`https://api.gocardless.com` or `https://api-sandbox.gocardless.com`)
* __SESSION_SECRET__: A random string for securing session data
* __REDIRECT_URI__: The redirect URI of your GoCardless app. (<http://localhost:9292/analytics`> if running locally with `bundle exec rackup`)
