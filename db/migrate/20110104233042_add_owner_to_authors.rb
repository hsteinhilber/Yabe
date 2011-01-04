class AddOwnerToAuthors < ActiveRecord::Migration
  def self.up
    add_column :authors, :owner, :boolean, :default => false
  end

  def self.down
    remove_column :authors, :owner
  end
end
