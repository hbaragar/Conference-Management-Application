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

ActiveRecord::Schema.define(:version => 20100128164528) do

  create_table "cfp_dates", :force => true do |t|
    t.integer "cfp_id"
    t.string  "label"
    t.string  "due_on_prefix", :default => ""
    t.date    "due_on"
  end

  add_index "cfp_dates", ["cfp_id"], :name => "index_cfp_dates_on_cfp_id"

  create_table "cfps", :force => true do |t|
    t.integer  "portfolio_id"
    t.date     "due_on"
    t.string   "format_style",  :default => "ACM Proceedings format"
    t.string   "format_url",    :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
    t.string   "submit_to_url", :default => "http://cyberchair.acm.org/splash???/submit/"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cfps", ["portfolio_id"], :name => "index_cfps_on_portfolio_id"

  create_table "conferences", :force => true do |t|
    t.integer "colocated_with_id"
    t.string  "name"
    t.text    "description"
  end

  add_index "conferences", ["colocated_with_id"], :name => "index_conferences_on_colocated_with_id"

  create_table "jos_categories", :force => true do |t|
    t.integer  "parent_id",                      :default => 0,     :null => false
    t.string   "title",                          :default => "",    :null => false
    t.string   "name",                           :default => "",    :null => false
    t.string   "alias",                          :default => "",    :null => false
    t.string   "image",                          :default => "",    :null => false
    t.string   "section",          :limit => 50, :default => "",    :null => false
    t.string   "image_position",   :limit => 30, :default => "",    :null => false
    t.text     "description",                                       :null => false
    t.boolean  "published",                      :default => false, :null => false
    t.integer  "checked_out",                    :default => 0,     :null => false
    t.datetime "checked_out_time",                                  :null => false
    t.string   "editor",           :limit => 50
    t.integer  "ordering",                       :default => 0,     :null => false
    t.integer  "access",           :limit => 1,  :default => 0,     :null => false
    t.integer  "count",                          :default => 0,     :null => false
    t.text     "params",                                            :null => false
  end

  add_index "jos_categories", ["access"], :name => "idx_access"
  add_index "jos_categories", ["checked_out"], :name => "idx_checkout"
  add_index "jos_categories", ["section", "published", "access"], :name => "cat_idx"

  create_table "jos_content", :force => true do |t|
    t.string   "title",                                :default => "", :null => false
    t.string   "alias",                                :default => "", :null => false
    t.string   "title_alias",                          :default => "", :null => false
    t.text     "introtext",        :limit => 16777215,                 :null => false
    t.text     "fulltext",         :limit => 16777215,                 :null => false
    t.integer  "state",            :limit => 1,        :default => 0,  :null => false
    t.integer  "sectionid",                            :default => 0,  :null => false
    t.integer  "mask",                                 :default => 0,  :null => false
    t.integer  "catid",                                :default => 0,  :null => false
    t.datetime "created",                                              :null => false
    t.integer  "created_by",                           :default => 0,  :null => false
    t.string   "created_by_alias",                     :default => "", :null => false
    t.datetime "modified",                                             :null => false
    t.integer  "modified_by",                          :default => 0,  :null => false
    t.integer  "checked_out",                          :default => 0,  :null => false
    t.datetime "checked_out_time",                                     :null => false
    t.datetime "publish_up",                                           :null => false
    t.datetime "publish_down",                                         :null => false
    t.text     "images",                                               :null => false
    t.text     "urls",                                                 :null => false
    t.text     "attribs",                                              :null => false
    t.integer  "version",                              :default => 1,  :null => false
    t.integer  "parentid",                             :default => 0,  :null => false
    t.integer  "ordering",                             :default => 0,  :null => false
    t.text     "metakey",                                              :null => false
    t.text     "metadesc",                                             :null => false
    t.integer  "access",                               :default => 0,  :null => false
    t.integer  "hits",                                 :default => 0,  :null => false
    t.text     "metadata",                                             :null => false
  end

  add_index "jos_content", ["access"], :name => "idx_access"
  add_index "jos_content", ["catid"], :name => "idx_catid"
  add_index "jos_content", ["checked_out"], :name => "idx_checkout"
  add_index "jos_content", ["created_by"], :name => "idx_createdby"
  add_index "jos_content", ["sectionid"], :name => "idx_section"
  add_index "jos_content", ["state"], :name => "idx_state"

  create_table "jos_menu", :force => true do |t|
    t.string   "menutype",         :limit => 75
    t.string   "name"
    t.string   "alias",                          :default => "",    :null => false
    t.text     "link"
    t.string   "type",             :limit => 50, :default => "",    :null => false
    t.boolean  "published",                      :default => false, :null => false
    t.integer  "parent",                         :default => 0,     :null => false
    t.integer  "componentid",                    :default => 0,     :null => false
    t.integer  "sublevel",                       :default => 0
    t.integer  "ordering",                       :default => 0
    t.integer  "checked_out",                    :default => 0,     :null => false
    t.datetime "checked_out_time",                                  :null => false
    t.integer  "pollid",                         :default => 0,     :null => false
    t.integer  "browserNav",       :limit => 1,  :default => 0
    t.integer  "access",           :limit => 1,  :default => 0,     :null => false
    t.integer  "utaccess",         :limit => 1,  :default => 0,     :null => false
    t.text     "params",                                            :null => false
    t.integer  "lft",                            :default => 0,     :null => false
    t.integer  "rgt",                            :default => 0,     :null => false
    t.integer  "home",                           :default => 0,     :null => false
  end

  add_index "jos_menu", ["componentid", "menutype", "published", "access"], :name => "componentid"
  add_index "jos_menu", ["menutype"], :name => "menutype"

  create_table "jos_sections", :force => true do |t|
    t.string   "title",                          :default => "",    :null => false
    t.string   "name",                           :default => "",    :null => false
    t.string   "alias",                          :default => "",    :null => false
    t.text     "image",                                             :null => false
    t.string   "scope",            :limit => 50, :default => "",    :null => false
    t.string   "image_position",   :limit => 30, :default => "",    :null => false
    t.text     "description",                                       :null => false
    t.boolean  "published",                      :default => false, :null => false
    t.integer  "checked_out",                    :default => 0,     :null => false
    t.datetime "checked_out_time",                                  :null => false
    t.integer  "ordering",                       :default => 0,     :null => false
    t.integer  "access",           :limit => 1,  :default => 0,     :null => false
    t.integer  "count",                          :default => 0,     :null => false
    t.text     "params",                                            :null => false
  end

  add_index "jos_sections", ["scope"], :name => "idx_scope"

  create_table "members", :force => true do |t|
    t.integer "portfolio_id"
    t.boolean "chair",                 :default => false
    t.string  "name"
    t.string  "affiliation"
    t.string  "private_email_address"
    t.integer "user_id"
    t.string  "country"
  end

  add_index "members", ["portfolio_id"], :name => "index_members_on_portfolio_id"
  add_index "members", ["user_id"], :name => "index_members_on_user_id"

  create_table "portfolios", :force => true do |t|
    t.integer "conference_id"
    t.string  "name"
    t.text    "description"
    t.string  "public_email_address"
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
