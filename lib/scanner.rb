
module Scannerset
	

	class Scanner

		attr_reader :content
			def content 
				return @content
			end

		def initialize(content)
			@content=content 
			@agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
		end

		def self.detect(content)
			if /\/spreadsheet\//=~content && content.length<200
				return ImageScanner.new(content)
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
			entries=[]
			ws = Session.spreadsheet_by_url(content).worksheets[0]
	  		rows=ws.rows.count
	  		for row in 1..ws.num_rows
	  			if /http/=~ws[row,2]
	  				staticrow=row
	  				image_url=ws[row,2]
	  				requested_title=ws[row,3]
	  				requested_alt=ws[row,4]
	  				if /http/=~ws[row,1]
	  					page_url=ws[row,1]
	  				elsif /http/!~ws[row,1]
	  					if ws[row,1]=="Page With Images"
	  						until /http/=~page_url do
		  						row+=1
		  						page_url=ws[row,1]
		  					end
		  				else
		  					until /http/=~page_url do
		  						row-=1
		  						page_url=ws[row,1]
		  					end
		  				end
	  				end
	  				page = pullpage(page_url)
	  				if page=="error"
	  					live_title="Page error."
	  					live_alt="Page error."
	  				else 
		  				image_source=image_url.split('/').last
		  				if page.at_css("img[src*='#{image_source}']")
			  				live_title=page.at_css("img[src*='#{image_source}']")[:title]
			  				live_alt=page.at_css("img[src*='#{image_source}']")[:alt]
			  			else 
			  				live_title="<i>Image does not exist on page.</i>"
			  				live_alt="<i>Image does not exist on page.</i>"
			  			end
		  			end
		  			meta={:page_url=>page_url,:image_url=>image_url,
		  				:title=>{:live=>live_title.to_s,:requested=>requested_title},
		  				:alt=>{:live=>live_alt.to_s,:requested=>requested_alt}}
	  				entries.push(Image.new(meta,staticrow,image_source,@content))
	  			end
	  		end
	  		return entries
		end

	end



	class ContentScanner < Scanner
		
		def pulldata(content)
				content_item=content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
		    	entries=Array.new
		    	count=0
		    	content_item.each do |co|
		      		co.each do |c|
		      			count+=1
				      	page_url=/URL:[[:space:]](.*$)/.match(c)
				      	page_url=page_url[1]
				      	if page_url !~/^http/
							page_url="http://#{page_url}"
						end		 
					    page = pullpage(page_url)
					    live_title=page.css("title").text
					    live_description = page.css("meta[@name$='escription']/@content").text
					    requested_title=/Page.Title.+?Tag\):(.*$)/.match(c)
					    requested_description=/Page.Description.+?Description\):(.*$)/.match(c)
						meta={:page_url=>page_url,
							:title=>{:live=>live_title,:requested=>requested_title[1]},
							:description=>{:live=>live_description,
							:requested=>requested_description[1]}}
						entries.push(Word.new(meta,count))
					end
				end
				return entries
			end

		end

end






