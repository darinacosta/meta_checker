require 'sinatra'
require 'mechanize'
require 'google_drive'
require 'open-uri'

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
  content=params[:URL1]
  if /\/spreadsheet\//=~content && content.length<200
  	@ws = session.spreadsheet_by_url("#{content}").worksheets[0]
  	rows=@ws.rows.count
  	erb :spreadsheet
  elsif /\/document\//=~content && content.length<200
  	"This is a document file."
  else
    contItem=content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
    @meta=Array.new
    contItem.each do |cont|
      cont.each do |c|
      URL=/URL:[[:space:]](.*$)/.match(c)
      html = agent.get("#{URL[1]}").body
      page = Nokogiri::HTML(html)
      liveTitle=page.css("title").text
      @liveDescrip = page.css("meta[@name$='escription']/@content")
      title=/Page.Title.+?Tag\):(.*$)/.match(c)
      descrip=/Page.Description.+?Description\):(.*$)/.match(c)
      @meta.push(
        :URL=>URL[1],
        :live=>{
          'title'=>liveTitle,
          'descrip'=>@liveDescrip
          },
        expected: {
          'title'=>title[1],
          'descrip'=>descrip[1]
          }
        )
    end
    end
    erb :raw
  end
end
