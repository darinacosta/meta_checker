require 'sinatra'
require 'mechanize'
require 'google_drive'
require 'open-uri'

configure :development do
  require 'pp'
  require 'dotenv'

  Dotenv.load
end

Session = GoogleDrive.login(ENV['GOOGLE_USER'], ENV['GOOGLE_PASS'])

require_relative 'lib/scanner.rb'

#Paths
get '/' do
  erb :form
end

post '/form' do
  input=params[:URL1]
  @meta=Scanner.detect(input)
  @meta=@meta.pulldata(input)
  erb :raw
end
