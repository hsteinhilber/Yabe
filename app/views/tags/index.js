$(function() {
  $("#post_tag_tokens").tokenInput("/tags.json", {
    hintText: "Enter a tag",
    noResultsText: "No tags found",
    preventDuplicates: true,
    prePopulate: $("#post_tag_tokens").data("pre")
  });
});
