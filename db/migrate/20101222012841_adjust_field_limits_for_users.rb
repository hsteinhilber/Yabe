class AdjustFieldLimitsForUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :email, :string, :limit => 75
    change_column :users, :name, :string, :limit => 75
    change_column :users, :encrypted_password, :string, :limit => 64
    change_column :users, :salt, :string, :limit => 64
  end

  def self.down
    change_column :users, :email, :string, :limit => 255
    change_column :users, :name, :string, :limit => 255
    change_column :users, :encrypted_password, :string, :limit => 255
    change_column :users, :salt, :string, :limit => 255
  end
end
