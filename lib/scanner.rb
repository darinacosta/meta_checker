
module Scannerset
	

	class Scanner

		def initialize(content)
			@@content=content 
			@agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
		end

		def self.detect(content)
			if /\/spreadsheet\//=~content && content.length<200
				return ImageScanner.new(content)
			elsif /\/document\//=~@@content && @@content.length<200
				return "To do: create word document parser!"
			else 
				return ContentScanner.new(content)
			end
		end

		def pullpage(uri)
			html = @agent.get(uri).body
			page = Nokogiri::HTML(html)
			return page
		rescue Mechanize::ResponseCodeError => e  
			page="error"
			return page
		end		

	end



	class ImageScanner < Scanner

		def pulldata(content)
			images=[]
			ws = Session.spreadsheet_by_url(content).worksheets[0]
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
	  				if page=="error"
	  					live_title="Page error."
	  					live_alt="Page error."
	  				else 
		  				urlpath=url.split('/').last
		  				live_title=page.at_css("img[src*='#{urlpath}']")[:title]
		  				live_alt=page.at_css("img[src*='#{urlpath}']")[:alt]
		  			end
	  				images.push(Image.new(parent_url,url,title,alt,live_title.to_s,live_alt.to_s,row))
	  			end
	  		end
	  		return images
		end

	end



	class ContentScanner < Scanner
		
		def pulldata(content)
				content_item=@@content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
		    	meta=Array.new
		    	content_item.each do |co|
		      		co.each do |c|
				      	url=/URL:[[:space:]](.*$)/.match(c)
				      	url=url[1]
				      	if url !~/^http/
							url="http://#{url}"
						end			 
					    page = pullpage(url)
					    live_title=page.css("title").text
					    live_description = page.css("meta[@name$='escription']/@@content").text
					    title=/Page.Title.+?Tag\):(.*$)/.match(c)
					    descrip=/Page.Description.+?Description\):(.*$)/.match(c)
						meta.push(Word.new(url,live_title,live_description,title[1],descrip[1]))
					end
				end
				return meta
			end

		end

	end



