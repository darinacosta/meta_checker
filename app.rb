def require_directory(folder)
  Dir["#{folder}/*"].each {|file| require_relative file }
end

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

require_directory('lib')
require_directory('helpers')

class MetaChecker < Sinatra::Base
  get '/' do
    erb :form
  end

  get '/instructions' do
    erb :instructions
  end


  post '/form' do
    user_input=params[:URL1]
    @meta=Scannerset::Scanner.detect(user_input).pull_data(user_input)
    if @meta.empty?
    	erb :empty
    else
    	erb :output
    end
  end
end
