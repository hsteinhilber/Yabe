module ApplicationHelper
  def title
    base_title = "Yet-Another-Blog-Engine (YABE)"
    if @title.nil? 
      base_title
    else
      "#{base_title} - #{@title}"
    end
  end
end
