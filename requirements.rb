def require_directory(folder)
  Dir["#{folder}/*"].each {|file| require_relative file }
end

#Standard Library
require "base64"
require 'open-uri'

#Bundler
require 'rubygems' 
require 'bundler/setup'

#Third Party
require 'sinatra'
require 'mechanize'
require 'google_drive'
require 'json'
require 'coffee-script'

configure :development do
  require 'pp'
  require 'dotenv'

  Dotenv.load
end

Session = GoogleDrive.login(ENV['GOOGLE_USER'], ENV['GOOGLE_PASS'])

require_directory('lib')
require_directory('helpers')