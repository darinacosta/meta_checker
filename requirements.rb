def require_directory(folder)
  Dir["#{folder}/*"].each {|file| require_relative file }
end

require 'sinatra'
require 'mechanize'
require 'google_drive'
require 'open-uri'
require 'json'
require "base64"

configure :development do
  require 'pp'
  require 'dotenv'

  Dotenv.load
end

Session = GoogleDrive.login(ENV['GOOGLE_USER'], ENV['GOOGLE_PASS'])

require_directory('lib')
require_directory('helpers')