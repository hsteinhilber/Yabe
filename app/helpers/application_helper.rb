module ApplicationHelper
  def title
    base_title = "Random Code Patterns"
    if @title.nil? 
      base_title
    else
      "#{base_title} - #{@title}"
    end
  end

  def logo
    image_tag("logo.png", :alt => "Random Code Patterns", :class => "round")
  end
end
