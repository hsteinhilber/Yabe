class AddIndexToTagName < ActiveRecord::Migration
  def self.up
    change_column :tags, :name, :string, :limit => 35
    add_index :tags, :name, :uniq => true
  end

  def self.down
    change_column :tags, :name, :string, :limit => nil
    remove_index :tags, :name
  end
end
