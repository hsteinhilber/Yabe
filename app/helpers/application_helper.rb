module ApplicationHelper

  SITE_TITLE = "Random Code Patterns"

  def title
    base_title = SITE_TITLE
    if @title.nil? 
      base_title
    else
      "#{base_title} - #{@title}"
    end
  end

  def logo
    image_tag("logo.png", :alt => SITE_TITLE, :class => "round")
  end
end
