require_relative "./scanner.rb"

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
      page_url = "http://#{page_url}" if page_url !~ /^http/
      page = pull_page_content(page_url)
      if page == "error"
        meta = return_error_view(page_url)
      else
        live_meta = scrape_live_meta(page)
        requested_meta = scrape_requested_meta(content_item)
        meta = { page_url:              page_url,
                 live_title:            live_meta[:live_title],
                 requested_title:       requested_meta[:requested_title],
                 live_description:      live_meta[:live_description],
                 requested_description: requested_meta[:requested_description]
                 }
      end
      return meta
    end

    def scrape_live_meta(page)
      live_title = page.css("title").text
      live_description = page.xpath("//meta[make_xpath_nodeset_case_insensitive(@name, 'description')]/@content", XpathFunctions.new).text
      return {
        live_title:       live_title,
        live_description: live_description
      }
    end

    def scrape_requested_meta(content)
      requested_title_match = /Page.Title.+?Tag\):(.*$)/.match(content)
      requested_title = requested_title_match[1]
      requested_description_match = /Page.Description.+?Description\):(.*$)/.match(content)
      requested_description = requested_description_match[1]
      return {
        requested_title:       requested_title,
        requested_description: requested_description
      }
    end

    def return_error_view(page_url)
      "<a href='#{page_url}' target='_blank'>#{page_url}</a> <span style='color: grey'>does not exist. Please ensure that the URL is formatted correctly.</span>"
    end
  end
end
