module AuthorsHelper

  def gravatar_for(author, options = { :size => 50 })
    gravatar_image_tag(author.email.downcase, :alt => author.name,
                                            :class => 'gravatar',
                                            :gravatar => options)
  end
                          
end
