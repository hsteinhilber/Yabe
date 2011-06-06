class AddMonthAndYearToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :month, :integer
    add_column :posts, :year, :integer
  end

  def self.down
    remove_column :posts, :year
    remove_column :posts, :month
  end
end
