require 'active_record'
require 'sinatra'
require 'erb'
require_relative 'models/user.rb'
require 'logger'
require 'net/HTTP'
require 'json'
require 'openssl'

post '/create/users' do
  @create_name = send_name
  @create_email = send_email
  @create_password = send_password
  @create_bio = send_bio

  haml :show
end