class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :post_id
      t.string :name
      t.string :url
      t.string :email
      t.string :body

      t.timestamps
    end
    add_index :comments, :post_id
  end

  def self.down
    drop_table :comments
  end
end
