
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
		images=[]
		ws = Session.spreadsheet_by_url(cont).worksheets[0]
  		rows=ws.rows.count
  		for row in 1..ws.num_rows
  			if /http/=~ws[row,1]
  				if /http/=~ws[row,2]
  					images.push(Image.new(ws[row,1],ws[row,2],ws[row,3],ws[row,4]))
  				end
  			elsif /http/=~ws[row,2] && /http/!~ws[row,1]
  				parent_url=ws[row,1]
  				url=ws[row,2]
  				title=ws[row,3]
  				alt=ws[row,4]
  				until /http/=~parent_url do
  					row-=1
  					parent_url=ws[row,1]
  				end
  				images.push(Image.new(parent_url,url,ws[row,3],ws[row,4]))
  			end 
  		end
  		return images
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



class Image

	def initialize(parent_url,url,alt,title)
		@url=url
		@parent_url=parent_url
		@alt=alt
		@title=title
	end

	def returl
		return "<b>Parent: </b>#{@parent_url}<br><b>Image: </b>#{@url}<br><b>Title: </b>#{@title}<br><br>"
	end
end


