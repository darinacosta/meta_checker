
class Scanner

	def initialize(cont)
		@cont=cont
	end

	def pulldata
		if /\/spreadsheet\//=~@cont && @cont.length<200
			@ws = Session.spreadsheet_by_url("#{@cont}").worksheets[0]
  			@rows=@ws.rows.count
		elsif /\/document\//=~@cont && @cont.length<200
			return "To do: create word document parser!"
		else
			agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
			contItem=@cont.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
	    	meta=Array.new
	    	contItem.each do |co|
	      		co.each do |c|
			      	url=/URL:[[:space:]](.*$)/.match(c)
				    html = agent.get("#{url[1]}").body
				    page = Nokogiri::HTML(html)
				    liveTitle=page.css("title").text
				    liveDescrip = page.css("meta[@name$='escription']/@content")
				    title=/Page.Title.+?Tag\):(.*$)/.match(c)
				    descrip=/Page.Description.+?Description\):(.*$)/.match(c)
					    meta.push(
					     	:url=>url[1],
					        :live=>{
					          'title'=>liveTitle,
					          'descrip'=>@liveDescrip
					          },
					        expected: {
					          'title'=>title[1],
					          'descrip'=>descrip[1]
					          }
					        )
					return "Still gotta make an ImageScanner class, but for now!:<br><br>", meta
				end
			end
		end
	end
end



