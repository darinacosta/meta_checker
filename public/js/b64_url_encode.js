function replace_word_characters(text) {
    var s = text;
    // smart single quotes and apostrophe
    s = s.replace(/[\u2018|\u2019|\u201A]/g, "\'");
    // smart double quotes
    s = s.replace(/[\u201C|\u201D|\u201E]/g, "\"");
    // ellipsis
    s = s.replace(/\u2026/g, "...");
    // dashes
    s = s.replace(/[\u2013|\u2014]/g, "-");
    // circumflex
    s = s.replace(/\u02C6/g, "^");
    // open angle bracket
    s = s.replace(/\u2039/g, "<");
    // close angle bracket
    s = s.replace(/\u203A/g, ">");
    // spaces
    s = s.replace(/[\u02DC|\u00A0]/g, " ");
    console.log(s)
    return s;
}


function base64_url_encode(input){
  //depends on strtr.js 
  smart_quote_sanitized_input = replace_word_characters(input)
  var base64_input = btoa(smart_quote_sanitized_input)
  var base64_url_encoded = strtr(base64_input, '+/=','-_,')
  return base64_url_encoded

}
