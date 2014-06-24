$(function() {

  for (var i = 0; i < requested_meta.length; i++) {
    if (requested_meta[i].error_view) {
      $("#meta_comparison_" + requested_meta[i].id).html("<table><tr><td style='width:34px;padding-left: 32px;'><b># " 
        + requested_meta[i].id + ":</b></td><td>" + requested_meta[i].error_view + "</td></tr></table><hr>");

    } else {
      
      var meta_data = {
        id: requested_meta[i].id,
        base64_url_encoded: base64_url_encode(requested_meta[i].page_url),
        requested_title_encoded: base64_url_encode(requested_meta[i].requested_title),
        requested_description_encoded: base64_url_encode(requested_meta[i].requested_description)
        };

        $.getJSON("/live_meta", meta_data, function(entry_output) {
          $("#meta_comparison_" + entry_output.id).html(entry_output.html);
      });
    }}
});
