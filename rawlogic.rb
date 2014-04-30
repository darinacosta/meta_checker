#requires
require_relative 'require.rb'

  if /\/spreadsheet\//=~@content && @content.length<200
    @ws = session.spreadsheet_by_url("#{@content}").worksheets[0]
    @rows=@ws.rows.count
    erb :spreadsheet
  elsif /\/document\//=~@content && @content.length<200
    "This is a document file."
  else
    @contItem=@content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
    @meta=Array.new
    @contItem.each do |cont|
      cont.each do |c|
      @URL=/URL:[[:space:]](.*$)/.match(c)
      html = agent.get("#{@URL[1]}").body
      @page = Nokogiri::HTML(html)
      @livetitle=@page.css("title").text
      @title=/Page.Title.+?Tag\):(.*$)/.match(c)
      @descrip=/Page.Description.+?Description\):(.*$)/.match(c)
      @meta.push({'Expected URL'=>'<a href="'+@URL[1]+'" target="_blank">'+@URL[1]+'</a>','Expected Title'=>@title[1],'Expected Description'=>@descrip[1]})
    end
    end    
    erb :raw
  end