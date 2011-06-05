# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110605162329) do

  create_table "authors", :force => true do |t|
    t.string   "name",               :limit => 75
    t.string   "email",              :limit => 75
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password", :limit => 64
    t.string   "salt",               :limit => 64
    t.text     "profile"
    t.boolean  "owner",                            :default => false
  end

  add_index "authors", ["email"], :name => "index_users_on_email", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.string   "name",       :limit => 75
    t.string   "url",        :limit => 150
    t.string   "email",      :limit => 75
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "posts", :force => true do |t|
    t.string   "title",        :limit => 75
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.datetime "published_on"
    t.string   "cached_slug"
  end

  add_index "posts", ["author_id"], :name => "index_posts_on_author_id"
  add_index "posts", ["cached_slug"], :name => "index_posts_on_cached_slug", :unique => true

  create_table "posts_tags", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "tag_id"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "tags", :force => true do |t|
    t.string "name", :limit => 35
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

end
