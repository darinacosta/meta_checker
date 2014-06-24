require_relative "./scanner.rb"

module Scannerset
  class ContentScanner < Scanner  
    def pull_data(content)
      unsorted_content_collection = content.scan(/(URL:.+?)(?:Cont(?:ent)? ?\d|.eyword(?:s)?:|CONT(?:ENT)? ?\d|-{3,}|On-Page|\Z)/m)
      content_array = Array.new
      content_order_id = 0
      unsorted_content_collection.each do |unsorted_content_item_set|
        unsorted_content_item_set.each do |unsorted_content_item|
          content_order_id += 1
          page_url = scrape_page_url(unsorted_content_item)
          meta = assemble_page_content_hash(page_url, unsorted_content_item)
          meta[:id] = content_order_id 
          content_array.push(meta)
        end
      end
      content_array
    end

    def scrape_page_url(raw_content)
      page_url = /URL:[[:space:]]*(.*$)/.match(raw_content)
      page_url = page_url[1]
      return page_url
    end
    
    def assemble_page_content_hash(page_url, content_item)
      page = pull_page_content(page_url)
      return requested_meta = return_error_view(page_url) if page == "error"
      requested_meta = scrape_requested_meta(content_item)
      requested_meta[:page_url] = page_url
      return requested_meta
    end

    def scrape_live_meta(page)
      live_title_raw = page.css("title").text
      live_description_raw = page.xpath("//meta[make_xpath_nodeset_case_insensitive(@name, 'description')]/@content", XpathFunctions.new).text
      live_title_sanitized = sanitize_content(live_title_raw)
      live_title = populate_if_empty(live_title_sanitized)
      live_description_sanitized = sanitize_content(live_description_raw)
      live_description = populate_if_empty(live_description_sanitized)
      return {
        live_title:       live_title,
        live_description: live_description
      }
    end

    def scrape_requested_meta(content)
      requested_title_match = /Page.Title.+?Tag\):(.*$)/.match(content)
      requested_title = populate_if_empty(requested_title_match)
      requested_description_match = /(?:Page|Meta)?.+?Description\)?:(.*)/.match(content)
      requested_description = populate_if_empty(requested_description_match)
      return {
        requested_title:       requested_title,
        requested_description: requested_description
      }
    end

    def return_error_view(page_url)
      {
        error_view: "<a href='#{page_url}' target='_blank'>#{page_url}</a><span style='color: grey'> does not exist. Please ensure that the URL is formatted correctly.</span>"
      }
    end
  end
end
