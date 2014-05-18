 module Scannerset
 
  class ImageScanner < Scanner

    def pull_data(content)
      entries = []
      worksheet = Session.spreadsheet_by_url(content).worksheets[0]
      rows = worksheet.rows.count
      for row in 1..worksheet.num_rows
        if /http/ =~ worksheet[row,2]
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
          meta = {:page_url=>page_url,
                  :image_url=>image_url,
                  :title=>{:live=>live_title.to_s,:requested=>requested_title},
                  :alt=>{:live=>live_alt.to_s,:requested=>requested_alt}}
          entries.push(Image.new(meta,static_row,image_source,content))
        end
      end
    return entries
    end

    def get_page_url(worksheet,row)
      if /http/ =~ worksheet[row,1]
        page_url = worksheet[row,1]
      elsif /http/ !~ worksheet[row,1]
        if worksheet[row,1] == "Page With Images"
          until /http/ =~ page_url do
            row += 1
            page_url = worksheet[row,1]
          end
        else
          until /http/ =~ page_url do
            row -= 1
            page_url = worksheet[row,1]
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
          live_alt = page.at_css("img[src*='#{image_source}']")[:alt]
        else 
          live_title = "<i>Image does not exist on page.</i>"
          live_alt = "<i>Image does not exist on page.</i>"
        end
      end
      return {:live_title=>live_title, :live_alt=>"live_alt"}
    end
  end

end