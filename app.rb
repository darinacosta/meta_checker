require_relative './requirements.rb'

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
