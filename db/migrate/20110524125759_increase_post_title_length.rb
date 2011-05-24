class IncreasePostTitleLength < ActiveRecord::Migration
  def self.up
    change_column :posts, :title, :string, :limit => 75
  end

  def self.down
    change_column :posts, :title, :string, :limit => 35
  end
end
