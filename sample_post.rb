require 'net/http'
require 'json'
require 'openssl'
require 'active_record'
require 'sinatra'
require 'erb'
require 'logger'
require './haml'

# Setup URI for HTTP connection
uri = URI('https://simple-auth.herokuapp.com/api/v1/users')
#uri = URI('http://localhost:4000/api/v1/users/')
http = Net::HTTP.new(uri.host, uri.port)

# Setup for HTTPS connection
http.use_ssl = true
# TODO: use VERIFY_PEER verification mode in production environment
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#create user
get '/create_user' do
  haml :create
end

post '/new_user' do
  @create_name = params["create_name"]
  @create_email = params["create_email"]
  @create_password = params["create_password"]
  @create_bio = params["create_bio"]

  # Setup HTTP request object
  req = Net::HTTP::Post.new(uri,
                            initheader = {'Content-Type' =>'application/json'})
  req.body = {
      name: @create_name, email:@create_email,
      password:@create_password, bio:@create_bio
  }.to_json

# Send request and wait for HTTP response
  res = http.request(req)


  haml :show
end

#user login
get '/login' do
  haml :login
end

post '/logining' do
  @login_name = params["login_name"]
  @login_password = params["login_password"]
  # Setup HTTP request object
  uri_login="https://simple-auth.herokuapp.com/api/v1/users"+"/"+@login_name+"/sessions"
  req = Net::HTTP::Post.new(uri_login,
                            initheader = {'Content-Type' =>'application/json'})
  req.body = {
      name: @login_name,
      password:@login_password
  }.to_json

# Send request and wait for HTTP response
  res = http.request(req)
end


