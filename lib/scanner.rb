
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
  				images.push(Image.new(parent_url,url,title,alt))
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
			      	url=url[1]
			      	if url !~/^http/
						url="http:\/\/"+url
					else
				    	html = agent.get("#{url}").body
				    end
				    page = Nokogiri::HTML(html)
				    liveTitle=page.css("title").text
				    liveDescrip = page.css("meta[@name$='escription']/@content")
				    title=/Page.Title.+?Tag\):(.*$)/.match(c)
				    descrip=/Page.Description.+?Description\):(.*$)/.match(c)
					meta.push(Content.new(url,liveTitle,liveDescrip,title[1],descrip[1]))
				end
			end
			return meta
		end
	end

##Create a "Content" parent class and let the image and content classes inherit the equivalency function

class Image

	def initialize(parent_url,url,alt,title)
		@url=url
		@parent_url=parent_url
		@alt=alt
		@title=title
	end

	def display
		return "<b>Parent: </b>#{@parent_url}<br><b>Image: </b>#{@url}<br><b>Title: </b>#{@title}<br><br>"
	end
end


class Content

	def initialize(url,livetitle,livedesc,title,desc)
		@url=url
		@livetitle=livetitle
		@livedesc=livedesc
		@title=title
		@desc=desc
	end

	def display

		def eq(live,exp)
			if live.strip==exp.strip
				live="<span style='color:green;'>#{live}</span>"
			else
				live="<span style='color:red;'>#{live}</span>"
			end
			return live
		end

		@livetitle=eq(@livetitle,@title)
		#@livedesc=eq(@livedesc,@desc)

		return "<b>URL: </b>#{@url}<br>
		<b>Expected Title: </b>#{@title}<br>
		<b>Live Title: </b>#{@livetitle}<br><br>
		<b>Expected Description: </b>#{@desc}<br>
		<b>Live Description: </b>#{@livedesc}<br><hr>"
	end
end


