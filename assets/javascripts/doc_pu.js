$(document).ready(function() {
  $(".doc-pu-button")
    .bind("ajax:success", function(event, data, status, xhr) {
      $("#log-result").html(data);
    });
});

