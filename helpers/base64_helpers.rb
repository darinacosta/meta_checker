class String
  def strtr(replace_pairs)
    keys = replace_pairs.map {|a, b| a }
    values = replace_pairs.map {|a, b| b }
    self.gsub(
      /(#{keys.map{|a| Regexp.quote(a) }.join( ')|(' )})/
      ) { |match| values[keys.index(match)] }
  
    # Call using a hash for the replacement pairs:
    #"AA BB".strtr("AA" => "BB", "BB" => "AA") #=> "BB AA"

  end

  def base64_url_decode
    url_decoded_variable = self.strtr("-" => "+", "_" => "/", "," => "=")
    Base64.decode64(url_decoded_variable)
  end
end
