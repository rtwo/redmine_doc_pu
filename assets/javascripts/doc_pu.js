$(document).ready(function() {
  $(".doc-pu-button")
    .bind("ajax:success", function(event, data, status, xhr) {
      $("#log-result").html(data);
    });
  $("input#doc_pu_wiki_full_page_name")
    .autocomplete({ source: 'list_wiki_pages.js' });
});

