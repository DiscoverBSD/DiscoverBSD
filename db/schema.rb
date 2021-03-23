# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_24_161504) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "author_id"
    t.string "title", null: false
    t.text "description", null: false
    t.string "url", null: false
    t.boolean "approved", default: false, null: false
    t.bigint "approved_by_id"
    t.datetime "approved_at"
    t.boolean "declined", default: false, null: false
    t.bigint "declined_by_id"
    t.datetime "declined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.index ["approved_by_id"], name: "index_posts_on_approved_by_id"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["declined_by_id"], name: "index_posts_on_declined_by_id"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "auth_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["auth_token"], name: "index_users_on_auth_token"
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "posts", "users", column: "approved_by_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "posts", "users", column: "declined_by_id"
end
