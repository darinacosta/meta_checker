class Scanner

	def initialize(content)
		@content=content
	end

	def self.detect(content)
		if /\/spreadsheet\//=~content && content.length<200
			return ImageScanner.new
		elsif /\/document\//=~content && content.length<200
  			return "This is a document file."
		else 
			return DocScanner.new
		end
	end
end

class ImageScanner < Scanner
	def pulldata
		@ws = session.spreadsheet_by_url("#{content}").worksheets[0]
  		@rows=@ws.rows.count
  	end
  end

class DocScanner < Scanner
	def pulldata(content)
		contItem=content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
    	meta=Array.new
    	contItem.each do |cont|
      		cont.each do |c|
		      	url=/URL:[[:space:]](.*$)/.match(c)
			    html = agent.get("#{URL[1]}").body
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
				    return meta
				end
			end
		end
	end

