module Scannerset

	class Content < Scanner 

		def match?(live,exp)
				if live.strip==exp.strip && live.strip!=""
					live="<span style='color:green;'>#{live}</span>"
				elsif live.strip==""
					live="<i>Empty.</i>"
				elsif !(live.strip==exp.strip) && !(live.strip=="")
					live="<span style='color:red;'>#{live}</span>"
				end
				return live
			end

		end



	class Image < Content

		def initialize(parent_url,url,title,alt,live_title,live_alt,row)
			@url=url
			@parent_url=parent_url
			@alt=alt
			@title=title
			@live_title=live_title
			@live_alt=live_alt
			@row=row
		end

		def display
			@live_title=match?(@live_title,@title)
			@live_alt=match?(@live_alt,@alt)

			return "<div class='imagerow'>
			<div class='imagewrapper'>
			<a href='#{@url}' target='_blank'>
			<img src='#{@url}' width='120px'></a>
			</div>
			<div class='metablock'><hr>
			<a href='#{@@content}' target='_blank'>
			<b>Row #{@row}</b></a>
			 | <a href='#{@parent_url}' target='_blank'>
			#{@parent_url}</a><br>
			<b>Title: </b>#{@title}<br>
			<b>Live Title:</b> #{@live_title}<br>
			<b>Alt:</b> #{@alt}<br>
			<b>Live Alt:</b> #{@live_alt}<br>
			<hr><br>
			</div>
			</div>"
		end

	end



	class Word < Content

		def initialize(url,live_title,live_description,title,description)
			@url=url
			@live_title=live_title
			@live_description=live_description
			@title=title
			@description=description
		end

		def display
			@live_title=match?(@live_title,@title)
			@live_description=match?(@live_description,@description)

			return "<b>URL: </b><a href='#{@url}' 
			target='_blank'>#{@url}</a><br>
			<b>Expected Title: </b>#{@title}<br>
			<b>Live Title: </b>#{@live_title}<br><br>
			<b>Expected Description: </b>#{@description}<br>
			<b>Live Description: </b>#{@live_description}<br><hr>"
		end

	end

end