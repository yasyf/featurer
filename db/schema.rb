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

ActiveRecord::Schema.define(version: 20150222024141) do

  create_table "docker_operations", force: :cascade do |t|
    t.string   "stage"
    t.text     "output",     default: ""
    t.boolean  "pending",    default: true
    t.boolean  "succeeded",  default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "feature_branches", force: :cascade do |t|
    t.string   "name"
    t.integer  "port"
    t.integer  "pr"
    t.string   "sha"
    t.integer  "repo_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "operation_id"
    t.integer  "docker_operation_id"
  end

  add_index "feature_branches", ["repo_id"], name: "index_feature_branches_on_repo_id"

  create_table "repos", force: :cascade do |t|
    t.string   "user"
    t.string   "name"
    t.string   "dockerfile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
