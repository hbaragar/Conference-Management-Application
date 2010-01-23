# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100123224127) do

  create_table "conferences", :force => true do |t|
    t.integer "colocated_with_id"
    t.string  "name"
    t.text    "description"
  end

  add_index "conferences", ["colocated_with_id"], :name => "index_conferences_on_colocated_with_id"

  create_table "members", :force => true do |t|
    t.integer "portfolio_id"
    t.boolean "chair",        :default => false
    t.string  "role",         :default => "member"
    t.string  "name"
    t.string  "affiliation"
    t.string  "email"
    t.integer "user_id"
  end

  add_index "members", ["portfolio_id"], :name => "index_members_on_portfolio_id"
  add_index "members", ["user_id"], :name => "index_members_on_user_id"

  create_table "portfolios", :force => true do |t|
    t.integer "conference_id"
    t.string  "name"
    t.text    "description"
    t.string  "email_address"
  end

  add_index "portfolios", ["conference_id"], :name => "index_portfolios_on_conference_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "active"
    t.datetime "key_timestamp"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end
