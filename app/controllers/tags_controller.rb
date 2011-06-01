class TagsController < ApplicationController
  def index
    tags = Tag.where('name like ?', "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => tags.map(&:attributes) }
      format.js
    end
  end

end
