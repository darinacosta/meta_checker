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
    @requested_meta = Scannerset::Scanner.detect(user_input).pull_data(user_input)
    @requested_meta_json = @requested_meta.to_json
    if @requested_meta.empty?
    	"Empty"
    else
      erb :output
    end
  end

  get '/live_meta/:id/:url/:requested_title/:requested_description' do
    id = id
    url = params[:url].to_s.base64_url_decode
    requested_title = params[:requested_title].to_s.base64_url_decode
    requested_description = params[:requested_description].to_s.base64_url_decode
    id = params[:id]
    content_scanner = Scannerset::ContentScanner.new
    live_page_content = content_scanner.pull_page_content(url)
    live_meta = content_scanner.scrape_live_meta(live_page_content)
    meta = {
      url:                   url,
      live_title:            live_meta[:live_title],
      live_description:      live_meta[:live_description],
      requested_title:       requested_title,
      requested_description: requested_description
    }
    word_profile = Scannerset::WordProfile.new(meta, id)
    return word_profile.display
  end
end





