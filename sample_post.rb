require 'net/HTTP'
require 'json'
require 'openssl'
require 'active_record'
require 'sinatra'
require 'erb'
require 'logger'
require 'rubygems'
require 'bcrypt'

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

password_salt = BCrypt::Engine.generate_salt

post '/new_user' do
  @create_name = params["create_name"]
  @create_email = params["create_email"]
  @create_password = params["create_password"]

  @create_password = BCrypt::Engine.hash_secret(params[:@create_password], password_salt)
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
