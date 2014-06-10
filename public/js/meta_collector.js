$(function() {
    var requested_meta = $.parseJSON(requested_meta_string);

    for (var i = 0; i < requested_meta.length; i++) {
        var meta_data = {
            id: requested_meta[i].id,
            base64_url_encoded: base64_url_encode(requested_meta[i].page_url),
            requested_title_encoded: base64_url_encode(requested_meta[i].requested_title),
            requested_description_encoded: base64_url_encode(requested_meta[i].requested_description)
        };

        $.get("/live_meta", meta_data, function(entry_output) {
            $("#meta_comparison_" + entry_point.id).html(entry_point.html);
        });
    }
});
