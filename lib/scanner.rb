
module Scannerset
	
	class Scanner
		attr_reader :user_input

		def initialize(user_input)
			@user_input = user_input 
			@agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
		end

		def self.detect(user_input)
			if /\/spreadsheet\// =~ user_input && user_input.length < 200
				return ImageScanner.new(user_input)
			else 
				return ContentScanner.new(user_input)
			end
		end

		def pull_page_content(url)
			#html = @agent.get(url).body
			page_content = Nokogiri::HTML(open(url), nil, 'UTF-8')
			return page_content
		rescue Mechanize::ResponseCodeError => e  
			page_content = "error"
			return page_content
		end		
	end

end