# frozen_string_literal: true

require 'sinatra'
require 'rack-flash'
require 'dotenv'
require 'prius'
require 'gocardless_pro'
require 'oauth2'

Dotenv.load
CLIENT_ID = Prius.load(:gocardless_client_id)
CLIENT_SECRET = Prius.load(:gocardless_client_secret)
CONNECT_URL = Prius.load(:gocardless_connect_url)
API_URL = Prius.load(:gocardless_api_url)
VERIFY_URL = Prius.load(:verify_url)
SESSION_SECRET = Prius.load(:session_secret)
REDIRECT_URI = Prius.load(:redirect_uri)
AUTHORIZE_PATH = Prius.load(:gocardless_connect_authorize_path)
ACCESS_TOKEN_PATH = Prius.load(:gocardless_connect_access_token_path)

use Rack::Session::Cookie, key: 'rack.session',
                           secret: SESSION_SECRET,
                           secure: true # disable this in non-SSL environments

use Rack::Flash, accessorize: %i[notice error]

OAUTH = OAuth2::Client.new(CLIENT_ID,
                           CLIENT_SECRET,
                           site: CONNECT_URL,
                           authorize_url: AUTHORIZE_PATH,
                           token_url: ACCESS_TOKEN_PATH)

error GoCardlessPro::Error do
  if env['sinatra.error'].code == 401
    session[:access_token] = nil
    flash[:error] = "Your access token is invalid - please reconnect your account."
  else
    flash[:error] = "Something went wrong. Please try again later."
  end

  redirect "/"
end

get '/' do
  redirect "/analytics" if session[:access_token]

  erb :index
end

get '/connect' do
  authorize_url = OAUTH.auth_code.authorize_url(redirect_uri: REDIRECT_URI,
                                                scope: "read_only",
                                                initial_view: "signup")

  redirect authorize_url
end

get "/logout" do
  session[:access_token] = nil
  flash[:notice] = "You have been successfully logged out."
  redirect "/"
end

get '/analytics' do
  if params[:code]
    token = OAUTH.auth_code.get_token(params[:code], redirect_uri: REDIRECT_URI)

    access_token = token.token
    session[:access_token] = access_token

    # Reload this page, but without the "code" in the URL. (This means that any refreshes
    # of the page won't try to exchange the code for an access token a second time,
    # causing the access tokens to be revoked.
    redirect "/analytics"
  elsif session[:access_token]
    access_token = session[:access_token]
  else
    flash[:error] = "You don't seem to be logged in at the moment."
    redirect "/"
  end

  gocardless = GoCardlessPro::Client.new(access_token: access_token,
                                         url: API_URL)

  @customer_count = gocardless.customers.all.count
  @payments = gocardless.payments.all
  @payment_count = @payments.count
  creditor = gocardless.creditors.list.records.first
  @verification_status = creditor.verification_status
  @payment_total = @payments.map { |payment| payment.amount / 100 }.inject(0, :+).round(2)
  @verify_url = VERIFY_URL
  erb :analytics
end

get '/onboarding-complete' do
  if session[:access_token]
    gocardless = GoCardlessPro::Client.new(access_token: session[:access_token],
                                           url: API_URL)
    creditor = gocardless.creditors.list.records.first
    @verification_status = creditor.verification_status
    erb :onboarding_complete
  else
    flash[:error] = "You don't seem to be logged in at the moment."
    redirect "/"
  end
end