require 'sinatra'
require 'mechanize'
require 'google_drive'
require 'open-uri'
require_relative 'lib/scanner.rb'

configure :development do
  require 'pp'
  require 'dotenv'

  Dotenv.load
end

session = GoogleDrive.login(ENV['GOOGLE_USER'], ENV['GOOGLE_PASS'])
agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

#Paths
get '/' do
  erb :form
end

post '/form' do
  cont=params[:URL1]
  @meta=Scanner.new(cont).pulldata
  erb :raw
end
