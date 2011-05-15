class AdjustedCommentFieldSizes < ActiveRecord::Migration
  def self.up
    change_column :comments, :name, :string, :limit => 75
    change_column :comments, :email, :string, :limit => 75
    change_column :comments, :url, :string, :limit => 150
    change_column :comments, :body, :string, :limit => 255
  end

  def self.down
    change_column :comments, :name, :string, :limit => nil
    change_column :comments, :email, :string, :limit => nil
    change_column :comments, :url, :string, :limit => nil
    change_column :comments, :body, :string, :limit => nil
  end
end
