class RenameUserToAuthor < ActiveRecord::Migration
  def self.up
    rename_table :users, :authors
  end

  def self.down
    rename_table :authors, :users
  end
end
