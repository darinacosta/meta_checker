require 'json'

module Scannerset

	class ContentProfile  
		def match?(live, exp)
			live = live.to_s
			return live = "<span style='color:green;'>#{live}</span>" if live.strip == exp.strip
			return live = "<span>#{live}</span>" if exp == "<i>None.</i>" || exp == "<i>Empty.</i>"
			live = "<span style='color:red;'>#{live}</span>"
		end
	end


	class ImageProfile < ContentProfile
		attr_reader :url, :parent_url, :alt, :title, :live_title, :live_alt, :row, :image_file_name, :spreadsheet_url

		def initialize(compiled_data, row, spreadsheet_url)
			@url = compiled_data[:image_url]
			@parent_url = compiled_data[:page_url]
			@alt = compiled_data[:alt][:requested]
			@title = compiled_data[:title][:requested]
			@live_title = compiled_data[:title][:live]
			@live_alt = compiled_data[:alt][:live]
			@image_file_name = compiled_data[:image_file_name]
			@row = row
			@spreadsheet_url = spreadsheet_url
		end

		def display
			live_title_compared = match?(live_title, title)
			live_alt_compared = match?(live_alt.to_s, alt)

			return "<div class='imagerow'>
			<div class='imagewrapper'> 
			<a href='#{url}' target='_blank'>
			<img src='#{url}'></a></div>
			<div class='metablock'><hr>
			<a href='#{spreadsheet_url}' target='_blank'>
			<b>Row #{row}</b></a>
			 | <a href='#{parent_url}' target='_blank'>
			#{parent_url}</a> | 
			#{image_file_name}<br>
			<table>
			<tr>
			<td class='left'><b>Title:</b></td><td>#{title}</td>
			</tr><tr>
			<td class='left'><b>Live:</b></td><td>#{live_title_compared}</td>
			</tr><tr>
			<td class='left'><b>Alt:</b></td><td>#{alt}</td>
			</tr><tr>
			<td class='left'><b>Live:</b></td><td>#{live_alt_compared}<br></td>
			</tr>
			</table>
			<hr><br>
			</div>
			</div>"
		end
	end


	class WordProfile < ContentProfile
		attr_accessor :url, :live_title, :live_description, :requested_title, :requested_description, :count

		def initialize(meta, count)
			@count = count
			@url = meta[:url]
			@live_title = meta[:live_title]
			@live_description = meta[:live_description]
			@requested_title = meta[:requested_title]
			@requested_description = meta[:requested_description]
			@count = count
		end

		def display
			live_title = match?(@live_title, requested_title)
			live_description = match?(@live_description, requested_description)
	
			{
				id: @count,
				html: "<table>
				<tr>
				<td class='left'><b># #{count}:</b></td><td><a href='#{url}' 
				target='_blank'>#{url}</a></td>
				</tr><tr>
				<td class='left'><b>Title:</b></td><td>#{requested_title}</td>
				</tr><tr>
				<td class='left'><b>Live:</b></td><td>#{live_title}</td>
				</tr><tr>
				<td class='left'><b>Descrip:</b></td><td>#{requested_description}</td>
				</tr><tr>
				<td class='left'><b>Live:</b></td><td>#{live_description}<br></td>
				</tr>
				</table><hr>"
			}.to_json
		end
	end

end
