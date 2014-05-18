
module Scannerset
	
	class Scanner
		attr_reader :content

		def initialize(content)
			@content = content 
			@agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
		end

		def self.detect(content)
			if /\/spreadsheet\// =~ content && content.length < 200
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
			page = "error"
			return page
		end		
	end

end