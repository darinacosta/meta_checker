require_relative '../requirements.rb'

module Scannerset
  class ContentScanner < Scanner  
    def pull_data(content)
      unsorted_content_collection = content.scan(/(URL:.+?)(?:Content|CONTENT|CONT|-{3,}|On-Page)/m)
      entries = Array.new
      count = 0
      unsorted_content_collection.each do |unsorted_content_item_set|
        unsorted_content_item_set.each do |unsorted_content_item|
          count += 1
          page_url = scrape_page_url(unsorted_content_item)
          meta = assemble_page_content_hash(page_url, unsorted_content_item)
          entries.push(WordProfile.new(meta, count))
        end
      end
      return entries
    end

    def scrape_page_url(raw_content)
      page_url = /URL:[[:space:]]*(.*$)/.match(raw_content)
      page_url = /URL:[[:space:]]*(.*$)/.match(raw_content)
      page_url = page_url[1]
      return page_url
    end
    
    def assemble_page_content_hash(page_url, content_item)
      if page_url !~ /^http/
        page_url = "http://#{page_url}"
      end    
      page = pull_page_content(page_url)
      if page == "error"
        meta = return_error(page_url)
      else
        live_title = page.css("title").text
        live_description = page.xpath("//meta[make_xpath_nodeset_case_insensitive(@name, 'description')]/@content", XpathFunctions.new).text
        requested_title = /Page.Title.+?Tag\):(.*$)/.match(content_item)
        if requested_title.nil?
          requested_title = [nil, nil]
        end
        requested_description = /Page.Description.+?Description\):(.*$)/.match(content_item)
        if requested_description.nil?
          requested_description = [nil, nil]
        end
        meta = { :page_url    => page_url,
                 :title       => { 
                   :live      => live_title,
                   :requested => requested_title[1]
                 },
                 :description => { 
                   :live      => live_description,
                   :requested => requested_description[1]
                 }
        }
      end
      return meta
    end

    def return_error(page_url)
      "<a href='#{page_url}' target='_blank'>#{page_url}</a> <span style='color: grey'>does not exist. Please ensure that the URL is formatted correctly.</span>"
    end
  end
end
