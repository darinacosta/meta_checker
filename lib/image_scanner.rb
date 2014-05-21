 module Scannerset
 
  class ImageScanner < Scanner
    def pull_data(spreadsheet_url)
      entries = []
      worksheet = Session.spreadsheet_by_url(spreadsheet_url).worksheets[0]
      for row in 1..worksheet.num_rows
        if /http/ =~ worksheet[row, 2]
          compiled_data = compile_data_from_worksheet_row(worksheet, row)
          entries.push(ImageProfile.new(compiled_data, row, spreadsheet_url))
        end
      end
    return entries
    end

    def compile_data_from_worksheet_row(worksheet, row)
      page_url = get_page_url(worksheet, row)
      page_content = pull_page_content(page_url)
      image_url = worksheet[row, 2]
      image_file_name = image_url.split('/').last
      requested_title = worksheet[row, 3]
      requested_alt = worksheet[row, 4]
      live_meta = get_live_image_meta(page_content, image_file_name)
      live_title = live_meta[:live_title]
      live_alt = live_meta[:live_alt]
      compiled_data = { 
        :page_url  => page_url,
        :image_url => image_url,
        :image_file_name => image_file_name,
        :title     => { 
          :live      => live_title.to_s,
          :requested => requested_title
        },
        :alt       => { 
          :live      => live_alt.to_s,
          :requested => requested_alt
        }
      }
      return compiled_data
    end

    def get_page_url(worksheet, row)
      if /http/ =~ worksheet[row, 1]
        page_url = worksheet[row, 1]
      elsif worksheet[row, 1] == "Page With Images"
        until /http/ =~ worksheet[row, 1] do
          row += 1
          page_url = worksheet[row, 1]
        end
      else
        until /http/ =~ page_url do
          row -= 1
          page_url = worksheet[row, 1]
        end
      end
      return page_url
    end

    def get_live_image_meta(page_content, image_file_name)
      if page_content == "error"
        live_title = "Page error."
        live_alt = "Page error."
      else 
        if page_content.at_css("img[src*='#{image_file_name}']")
          live_title = page_content.at_css("img[src*='#{image_file_name}']")[:title]
          live_alt = page_content.at_css("img[src*='#{image_file_name}']")[:alt]
        else 
          live_title = "<i>Image does not exist on page.</i>"
          live_alt = "<i>Image does not exist on page.</i>"
        end
      end
      return { 
        :live_title => live_title, 
        :live_alt   => live_alt 
      }
    end
  end

end