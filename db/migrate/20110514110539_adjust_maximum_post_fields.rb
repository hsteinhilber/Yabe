class AdjustMaximumPostFields < ActiveRecord::Migration
  def self.up
    change_column :posts, :body, :text, :limit => nil
    change_column :posts, :title, :string, :limit => 35
  end

  def self.down
    change_column :posts, :body, :string, :limit => nil
    change_column :posts, :title, :string, :limit => nil
  end
end
