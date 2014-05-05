
class Scanner

	def initialize(cont)
		@cont=cont 
		@agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
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

	def pullpage(uri)
		html = @agent.get(uri).body
		page = Nokogiri::HTML(html)
		return page
	end		

end



class ImageScanner < Scanner

	def pulldata(cont)
		images=[]
		ws = Session.spreadsheet_by_url(cont).worksheets[0]
  		rows=ws.rows.count
  		for row in 1..ws.num_rows
  			if /http/=~ws[row,2]
  				url=ws[row,2]
  				title=ws[row,3]
  				alt=ws[row,4]
  				if /http/=~ws[row,1]
  					parent_url=ws[row,1]
  				elsif /http/!~ws[row,1]
  					until /http/=~parent_url do
  						row-=1
  						parent_url=ws[row,1]
  					end
  				end
  				page = pullpage(parent_url)
  				urlpath=url.split('/').last
  				liveTitle=page.at_css("img[src*='#{urlpath}']")[:title]
  				liveAlt=page.at_css("img[src*='#{urlpath}']")[:alt]
  				images.push(Image.new(parent_url,url,title,alt,liveTitle.to_s,liveAlt.to_s))
  			end
  		end
  		return images
	end

end



class ContentScanner < Scanner
	
	def pulldata(cont)
			contItem=@cont.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
	    	meta=Array.new
	    	contItem.each do |co|
	      		co.each do |c|
			      	url=/URL:[[:space:]](.*$)/.match(c)
			      	url=url[1]
			      	if url !~/^http/
						url="http://#{url}"
					end			 
				    page = pullpage(url)
				    liveTitle=page.css("title").text
				    liveDescrip = page.css("meta[@name$='escription']/@content").text
				    title=/Page.Title.+?Tag\):(.*$)/.match(c)
				    descrip=/Page.Description.+?Description\):(.*$)/.match(c)
					meta.push(Word.new(url,liveTitle,liveDescrip,title[1],descrip[1]))
				end
			end
			return meta
		end

	end



class Content

	def match?(live,exp)
			if live.strip==exp.strip && live.strip!=""
				live="<span style='color:green;'>#{live}</span>"
			elsif live.strip==""
				live="<i>Empty.</i>"
			elsif live.strip!=exp.strip && live.strip!=""
				live="<span style='color:red;'>#{live}</span>"
			end
			return live
		end

	end



class Image < Content

	def initialize(parent_url,url,title,alt,liveTitle,liveAlt)
		@url=url
		@parent_url=parent_url
		@alt=alt
		@title=title
		@liveTitle=liveTitle
		@liveAlt=liveAlt
	end

	def display
		@liveTitle=match?(@liveTitle,@title)
		@liveAlt=match?(@liveAlt,@alt)

		return "<div class='imagerow'>
		<div class='imagewrapper'>
		<img src='#{@url}' width='120px'>
		</div>
		<div class='metablock'>
		<b>Parent: </b>#{@parent_url}<br>
		<b>Image: </b>#{@url}<br>
		<b>Title: </b>#{@title}<br>
		<b>Live Title:</b> #{@liveTitle}<br>
		<b>Alt:</b> #{@alt}<br>
		<b>Live Alt:</b> #{@liveAlt}<br>
		<hr><br>
		</div>
		</div>"
	end

end



class Word < Content

	def initialize(url,livetitle,livedesc,title,desc)
		@url=url
		@livetitle=livetitle
		@livedesc=livedesc
		@title=title
		@desc=desc
	end

	def display
		@livetitle=match?(@livetitle,@title)
		@livedesc=match?(@livedesc,@desc)

		return "<b>URL: </b><a href='#{@url}' 
		target='_blank'>#{@url}</a><br>
		<b>Expected Title: </b>#{@title}<br>
		<b>Live Title: </b>#{@livetitle}<br><br>
		<b>Expected Description: </b>#{@desc}<br>
		<b>Live Description: </b>#{@livedesc}<br><hr>"
	end

end


