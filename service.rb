require 'active_record'
require 'sinatra'
require 'erb'
require_relative 'models/user.rb'
require 'logger'
require 'net/HTTP'
require 'json'
require 'openssl'
require 'rubygems'

# Setup URI for HTTP connection
#uri = URI('https://stark-hamlet-1008.herokuapp.com/api/v1/users')
#uri = URI('http://localhost:4000/api/v1/users/')
http = Net::HTTP.new(uri.host, uri.port)

# Setup for HTTPS connection
http.use_ssl = true
# TODO: use VERIFY_PEER verification mode in production environment
http.verify_mode = OpenSSL::SSL::VERIFY_NONE


# setting up a logger. levels -> DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

# DISCOVERING WHICH ENVIRONMENT IS REQUESTED
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV["SINATRA_ENV"] || "development"
log.debug "env: #{env}"

# connecting to the database
use ActiveRecord::ConnectionAdapters::ConnectionManagement # close connection to the DDBB properly...https://github.com/puma/puma/issues/59
databases = YAML.load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(databases[env])
log.debug "#{databases[env]['database']} database connection established..."

# creating fixture data (only in test mode)
if env == 'test'
  User.destroy_all
  User.create(
   :name => "paul",
   :email => "paul@pauldix.net",
   :bio => "rubyist")
  log.debug "fixture data created in test database..."
elsif env == 'development'
  unless User.find_by_email('syray@mx.nthu.edu.tw')
    User.create(
     :name => 'Lei',
     :email => 'syray@mx.nthu.edu.tw',
     :bio => 'lao shi')
    log.debug 'fixture data created in development database...'
  end
elsif env == 'production'
  unless User.find_by_email('soumya.ray.nthu@gmail.com') 
    User.create(
     :name => 'Soumya',
     :email => 'soumya.ray.nthu@gmail.com',
     :bio => 'rubyist')
    log.debug 'fixture data created in production database...'
  end
end

# the HTTP entry points to our service

# get a user by name
get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
  else
    error 404, {:error => "user not found"}.to_json # :not_found
  end
end



# update an existing user
put '/api/v1/users/:name' do
  user = User.find_by_name(params['name'])
  if user
    begin
      attributes = JSON.parse(request.body.read)
      updated_user = user.update_attributes(attributes)
      if updated_user
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue => e
      error 400, {:error => e.message}.to_json
    end
  else
    error 404, {:error => 'user not found'}.to_json
  end
end

# destroy an existing user
delete '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.destroy
    user.to_json
  else
    error 404, {:error => 'user not found'}.to_json
  end
end

# create a new user
post '/api/v1/users' do
  begin
    user = User.create(JSON.parse(request.body.read))
    if user.valid?
      user.to_json
      uri = URI('http://cryptic-wildwood-4595.herokuapp.com/create_successful')
      NET::HTTP.get(uri)
    else
      error 400, user.errors.to_json # :bad_request
    end
  rescue => e
    error 400, {:error => e.message}.to_json
  end
end

# verify a user name and password
post '/api/v1/users/:name/sessions' do
  begin
    attributes = JSON.parse(request.body.read)
    user = User.find_by_name_and_password(params[:name],attributes['password'])
    if user
      user.to_json
    else
      error 400, {:error => 'invalid user or credentials'}.to_json
    end
  rescue => e
    error 400, {:error => e.message}.to_json
  end
end


#
# HELPERS
#

def show_request(request,log)
  log.debug "request.request_method: #{request.request_method}"
  log.debug "request.body: #{request.body}"
  #log.debug "request.cookies: #{request.cookies}"
  #log.debug "request.env: #{request.env}"
  log.debug "request.content_length: #{request.content_length}"
  log.debug "request.media_type: #{request.media_type}"
end

get '/foo' do
  show_request(request, log)
end
