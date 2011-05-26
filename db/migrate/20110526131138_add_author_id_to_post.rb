class AddAuthorIdToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :author_id, :integer
    add_index :posts, :author_id
  end

  def self.down
    remove_index :posts, :author_id
    remove_column :posts, :author_id
  end
end
