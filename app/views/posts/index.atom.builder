atom_feed do |feed|
  feed.title("Random Code Patterns")
  feed.update(@posts.first.created_at)

  @posts.each do |post|
    feed.entry(post) do |entry|
      entry.title(post.title)
      entry.content(post.body, :type => 'html')
      entry.author { |author| author.name("Harry Steinhilber, Jr.") }
    end
  end
end
