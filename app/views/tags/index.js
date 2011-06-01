$(function() {
  $("#post_tag_tokens").tokenInput("/tags.json", {
    crossDomain: false,
    prePopulate: $("#post_tag_tokens").data("pre")
  });
});
