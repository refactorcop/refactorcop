# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151101092724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "username",               limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "repository_data"
    t.integer  "source_files_count",                 default: 0,     null: false
    t.integer  "rubocop_offenses_count",             default: 0,     null: false
    t.datetime "rubocop_run_started_at"
    t.datetime "rubocop_last_run_at"
    t.boolean  "has_todo",                           default: false, null: false
  end

  create_table "rubocop_offenses", force: :cascade do |t|
    t.string   "severity",        limit: 255, null: false
    t.text     "message"
    t.string   "cop_name",        limit: 255
    t.integer  "location_line"
    t.integer  "location_column"
    t.integer  "location_length"
    t.integer  "source_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rubocop_offenses", ["cop_name"], name: "index_rubocop_offenses_on_cop_name", using: :btree
  add_index "rubocop_offenses", ["severity"], name: "index_rubocop_offenses_on_severity", using: :btree
  add_index "rubocop_offenses", ["source_file_id"], name: "index_rubocop_offenses_on_source_file_id", using: :btree

  create_table "source_files", force: :cascade do |t|
    t.integer  "project_id"
    t.text     "content"
    t.string   "path",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "source_files", ["project_id"], name: "index_source_files_on_project_id", using: :btree

end
