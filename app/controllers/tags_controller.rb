class TagsController < ApplicationController
  def index
    tags = Tag.where('name like ?', "%#{params[:q]}%")
      .take(10).map { |t| { :id => t.id, :name => t.name } }

    unless has_match(tags)
      tags = [{ 
               :id => "[#{params[:q]}]", 
               :name => "Add - #{params[:q]}" 
             }] + tags.take(9)
    end

    respond_to do |format|
      format.json { render :json => tags }
      format.js
    end
  end

  private
    def has_match(tags)
      return true if params[:q].nil?
      
      tags.any? do |t| 
        t[:name].casecmp(params[:q].tap{|x|p x}) == 0 
      end
    end

end
