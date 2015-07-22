require 'rubygems'
require 'sinatra'
require 'prius'
require 'dotenv'
require 'gocardless_pro'
require 'oauth2'

configure { set :server, :puma }

Dotenv.load
CLIENT_ID = Prius.load(:gocardless_client_id)
CLIENT_SECRET = Prius.load(:gocardless_client_secret)
CONNECT_URL = Prius.load(:gocardless_connect_url)
API_URL = Prius.load(:gocardless_api_url)
SESSION_SECRET = Prius.load(:session_secret)
REDIRECT_URI = Prius.load(:redirect_uri)
AUTHORIZE_PATH = Prius.load(:gocardless_connect_authorize_path)
ACCESS_TOKEN_PATH = Prius.load(:gocardless_connect_access_token_path)

enable :sessions
set :session_secret, SESSION_SECRET

OAUTH = OAuth2::Client.new(CLIENT_ID,
                           CLIENT_SECRET,
                           site: CONNECT_URL,
                           authorize_url: AUTHORIZE_PATH,
                           token_url: ACCESS_TOKEN_PATH)

# Customer visits the site. Hi Customer!
get '/' do
  erb :index
end

# Customer purchases an item
get '/connect' do
  authorize_url = OAUTH.auth_code.authorize_url(redirect_uri: REDIRECT_URI,
                                                scope: "read_only")

  redirect authorize_url
end

get "/reset" do
  session[:access_token] = nil
  redirect "/"
end

get '/analytics' do
  if params[:code]
    token = OAUTH.auth_code.get_token(params[:code], redirect_uri: REDIRECT_URI)

    access_token = token.token
    session[:access_token] = access_token
  elsif session[:access_token]
    access_token = session[:access_token]
  else
    redirect "/"
  end

  gocardless = GoCardlessPro::Client.new(access_token: access_token,
                                         url: API_URL)

  @customer_count = gocardless.customers.all.count
  @payments = gocardless.payments.all
  @payment_count = @payments.count
  @payment_total = @payments.map { |payment| payment.amount / 100 }.inject(0, :+).round(2)
  erb :analytics
end
