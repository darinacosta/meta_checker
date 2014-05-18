module Scannerset

	class Content  
		def match?(live, exp)
			if live.strip == exp.strip && live.strip != ""
				live = "<span style='color:green;'>#{live}</span>"
			elsif live.strip == ""
				live = "<i>Empty.</i>"
			elsif !(live.strip==exp.strip) && !(live.strip=="")
				live = "<span style='color:red;'>#{live}</span>"
			end
			return live
		end
	end



	class Image < Content
		def initialize(meta, row, image_source,content)
			@url = meta[:image_url]
			@parent_url = meta[:page_url]
			@alt = meta[:alt][:requested]
			@title = meta[:title][:requested]
			@live_title = meta[:title][:live]
			@live_alt = meta[:alt][:live]
			@row = row
			@image_source = image_source
			@content = content
		end

		def display
			@live_title = match?(@live_title,@title)
			@live_alt = match?(@live_alt,@alt)

			return "<div class='imagerow'>
			<div class='imagewrapper'>
			<a href='#{@url}' target='_blank'>
			<img src='#{@url}'></a></div>
			<div class='metablock'><hr>
			<a href='#{@content}' target='_blank'>
			<b>Row #{@row}</b></a>
			 | <a href='#{@parent_url}' target='_blank'>
			#{@parent_url}</a> | 
			#{@image_source}<br>
			<table>
			<tr>
			<td class='left'><b>Title:</b></td><td>#{@title}</td>
			</tr><tr>
			<td class='left'><b>Live:</b></td><td>#{@live_title}</td>
			</tr><tr>
			<td class='left'><b>Alt:</b></td><td>#{@alt}</td>
			</tr><tr>
			<td class='left'><b>Live:</b></td><td>#{@live_alt}<br></td>
			</tr>
			</table>
			<hr><br>
			</div>
			</div>"
		end
	end


	class Word < Content
		def initialize(meta, count)
			@url = meta[:page_url]
			@live_title = meta[:title][:live]
			@live_description = meta[:description][:live]
			@title = meta[:title][:requested]
			@description = meta[:description][:requested]
			@count = count
		end

		def display
			@live_title = match?(@live_title,@title)
			@live_description = match?(@live_description,@description)

			return "<b>Content #{@count}: </b><a href='#{@url}' 
			target='_blank'>#{@url}</a><br>
			<b>Expected Title: </b>#{@title}<br>
			<b>Live Title: </b>#{@live_title}<br><br>
			<b>Expected Description: </b>#{@description}<br>
			<b>Live Description: </b>#{@live_description}<br><hr>"
		end
	end

end