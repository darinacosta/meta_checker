module Scannerset

  class ContentScanner < Scanner
    
    def pull_data(content)
      content_item = content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
      entries = Array.new
      count = 0
      content_item.each do |co|
        co.each do |c|
          count += 1
          page_url=/URL:[[:space:]](.*$)/.match(c)
          page_url=page_url[1]
          if page_url !~/^http/
            page_url="http://#{page_url}"
          end    
            page = pull_page(page_url)
            live_title = page.css("title").text
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
