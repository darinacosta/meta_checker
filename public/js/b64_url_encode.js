function base64_url_encode(input){

  //depends on strtr.js 
  var base64_input = btoa(input)
  var base64_url_encoded = strtr(base64_input, '+/=','-_,')
  return base64_url_encoded

}