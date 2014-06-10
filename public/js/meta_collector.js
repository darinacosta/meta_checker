$(function() {

  for (var i = 0; i < requested_meta.length; i++) {
  console.log(requested_meta[i]);
  var meta_data = {
    id: requested_meta[i].id,
    base64_url_encoded: base64_url_encode(requested_meta[i].page_url),
    requested_title_encoded: base64_url_encode(requested_meta[i].requested_title),
    requested_description_encoded: base64_url_encode(requested_meta[i].requested_description)
    };

    $.getJSON("/live_meta" + "/" + meta_data.id + "/" + meta_data.base64_url_encoded + "/" + meta_data.requested_title_encoded + "/" + meta_data.requested_description_encoded, function(entry_output) {
    $("#meta_comparison_" + entry_output.id).html(entry_output.html);
    });
  }
});
