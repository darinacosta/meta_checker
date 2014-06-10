$(document).ready( function() {
    var requested_meta = $.parseJSON(requested_meta_string)
    var requested_meta_length = requested_meta.length

    for (var i = 0; i < requested_meta_length; i++){

      var div = $('<div />');
      console.log(div);
      $( "#meta_test" ).append(div);

      var base64_url_encoded = base64_url_encode(requested_meta[i].page_url)
      var requested_title_encoded = base64_url_encode(requested_meta[i].requested_title)
      var requested_description_encoded = base64_url_encode(requested_meta[i].requested_description)
      var id = requested_meta[i].id; 

      $.get( "/live_meta/" + id + '/' + base64_url_encoded + '/' + requested_title_encoded + '/' + requested_description_encoded, function(entry_output){

      div.append(entry_output);
    });
    }
  });