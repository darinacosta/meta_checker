
class Scanner

	def initialize(cont)
		@cont=cont 
	end

	def self.detect(cont)
		if /\/spreadsheet\//=~cont && cont.length<200
			return ImageScanner.new(cont)
		elsif /\/document\//=~@cont && @cont.length<200
			return "To do: create word document parser!"
		else 
			return ContentScanner.new(cont)
		end
	end
end



class ImageScanner < Scanner

	def pulldata(cont)
		#Create a page class, an images class
		pages=[]
		ws = Session.spreadsheet_by_url(cont).worksheets[0]
  		rows=ws.rows.count
  		for row in 1..ws.num_rows
  			if /http/=~ws[row,1]
  				meta.push("#{ws[row,1]}"=>[])
  				if /http/=~ws[row,2]
  					#put in hash1=>hash
  				end
  			elsif ws[row,1]==""
  				if /http/=~ws[row,2]
  					#put in hash1=>hash
  				end
  			end
  		end
	end
end



class ContentScanner < Scanner
	
	def pulldata(cont)
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


