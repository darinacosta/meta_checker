
module Scannerset
	

	class Scanner
		attr_reader :content

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

		def pull_page(uri)
			#html = @agent.get(uri).body
			page = Nokogiri::HTML(open(uri), nil, 'UTF-8')
			return page
		rescue Mechanize::ResponseCodeError => e  
			page="error"
			return page
		end		

	end



	class ImageScanner < Scanner

		def pull_data(content)
			entries=[]
			worksheet = Session.spreadsheet_by_url(content).worksheets[0]
	  	rows=worksheet.rows.count
	  	for row in 1..worksheet.num_rows
	  		if /http/=~worksheet[row,2]
	  			static_row = row
	  			page_url = get_page_url(worksheet, row)
	  			page = pull_page(page_url)
	  			image_url = worksheet[row,2]
	  			image_source = image_url.split('/').last
	  			requested_title = worksheet[row,3]
	  			requested_alt = worksheet[row,4]
	  			live_meta = get_live_image_meta(page, image_source)
	  			live_title = live_meta[:live_title]
	  			live_alt = live_meta[:live_alt]
		  		meta={:page_url=>page_url,
		  			:image_url=>image_url,
		  			:title=>{:live=>live_title.to_s,:requested=>requested_title},
		  			:alt=>{:live=>live_alt.to_s,:requested=>requested_alt}}
	  			entries.push(Image.new(meta,static_row,image_source,content))
	  		end
	  	end
	  return entries
	  end

	def get_page_url(worksheet,row)
	  if /http/=~worksheet[row,1]
	    page_url=worksheet[row,1]
	  elsif /http/!~worksheet[row,1]
	    if worksheet[row,1]=="Page With Images"
	      until /http/=~page_url do
	        row+=1
	        page_url=worksheet[row,1]
	      end
	    else
	      until /http/=~page_url do
	        row-=1
	        page_url=worksheet[row,1]
	      end
	    end
	  end
	  return page_url
	end

	def get_live_image_meta(page, image_source)
	  if page == "error"
	    live_title = "Page error."
	    live_alt = "Page error."
	  else 
	    if page.at_css("img[src*='#{image_source}']")
	      live_title = page.at_css("img[src*='#{image_source}']")[:title]
	      live_alt=page.at_css("img[src*='#{image_source}']")[:alt]
	    else 
	      live_title = "<i>Image does not exist on page.</i>"
	      live_alt = "<i>Image does not exist on page.</i>"
	    end
	  end
	  return {:live_title=>live_title, :live_alt=>"live_alt"}
	end
end


	class ContentScanner < Scanner
		
		def pull_data(content)
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
					    page = pull_page(page_url)
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






