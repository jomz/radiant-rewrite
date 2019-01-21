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

ActiveRecord::Schema.define(version: 2019_01_19_230949) do

  create_table "radiant_pages", force: :cascade do |t|
    t.string "title"
    t.string "slug", limit: 100
    t.string "breadcrumb", limit: 160
    t.integer "status_id", default: 1, null: false
    t.integer "parent_id"
    t.datetime "published_at"
    t.boolean "virtual", default: false
    t.integer "lock_version", default: 0
    t.string "class_name", limit: 25
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_name"], name: "pages_class_name"
    t.index ["parent_id"], name: "pages_parent_id"
    t.index ["slug", "parent_id"], name: "pages_child_slug"
    t.index ["virtual", "status_id"], name: "pages_published"
  end

end