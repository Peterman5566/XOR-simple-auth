require 'net/HTTP'
require 'json'
require 'openssl'
require 'active_record'
require 'sinatra'
require 'erb'
require 'logger'
require 'net/HTTP'

# Setup URI for HTTP connection
uri = URI('https://simple-auth.herokuapp.com/api/v1/users/:name/sessions')
#uri = URI('http://localhost:4000/api/v1/users/')
http = Net::HTTP.new(uri.host, uri.port)

# Setup for HTTPS connection
http.use_ssl = true
# TODO: use VERIFY_PEER verification mode in production environment
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#user login
get '/login' do
  haml :login
end

post '/logining' do
  @login_name = params["login_name"]
  @login_password = params["login_password"]

  # Setup HTTP request object
  req = Net::HTTP::Post.new('https://simple-auth.herokuapp.com/api/v1/users/@login_name/sessions',
                            initheader = {'Content-Type' =>'application/json'})
  req.body = {
      name: @login_name,
      password:@login_password
  }.to_json

# Send request and wait for HTTP response
  res = http.request(req)

  #haml :show
end

