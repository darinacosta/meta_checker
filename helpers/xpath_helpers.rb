class XpathFunctions
  def make_xpath_nodeset_case_insensitive(node_set, str_to_match)
    node_set.find_all {|node| node.to_s.downcase == str_to_match.to_s.downcase }
  end
end