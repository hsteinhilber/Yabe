module PostsHelper
  def render_editor_links(post)
    return unless can_edit_post?(post)

    raw("<p>" + link_to('Edit', edit_post_path(post)) + ' | ' +
      link_to('Delete', post, :method => :delete, :confirm => "Are you sure?") +
      "</p>")
  end

  def can_edit_post?(post)
    logged_in? && 
      (current_author.owner? || current_author.id == post.author_id)
  end
end
