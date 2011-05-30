class AddPublishedOnToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :published_on, :datetime
  end

  def self.down
    remove_column :posts, :published_on
  end
end
