def sanitize_content(string)
  string.gsub!(/(\xE2\x80\x98|\xE2\x80\x99)/, "'")
  string.gsub!(/(\xE2\x80\x9C|\xE2\x80\x9D)/, '"')
  string.gsub!(/(\xE2\x80\x93|\xE2\x80\x94)/, "-")
  string.gsub!(/\xE2\x80\xA6/, "...")
  string.gsub!(/\xe2\x80\xa2/, "*")
  string.gsub!(/\u00a0/, " ") #no break space
  string.gsub!(/\u2019/, "'")
  string.gsub!(/&#039;/, "'")
  string.gsub!(/\u2028/, "\n") #line seperator
  return string
end