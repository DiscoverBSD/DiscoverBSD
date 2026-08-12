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

ActiveRecord::Schema[8.1].define(version: 2026_08_12_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "posts", force: :cascade do |t|
    t.boolean "approved", default: false, null: false
    t.datetime "approved_at", precision: nil
    t.bigint "approved_by_id"
    t.bigint "author_id"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "declined", default: false, null: false
    t.datetime "declined_at", precision: nil
    t.bigint "declined_by_id"
    t.text "description", null: false
    t.string "newsletter_part", default: "news", null: false
    t.datetime "scheduled_for"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "url", null: false
    t.index ["approved_by_id"], name: "index_posts_on_approved_by_id"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["declined_by_id"], name: "index_posts_on_declined_by_id"
    t.index ["newsletter_part"], name: "index_posts_on_newsletter_part"
    t.index ["scheduled_for"], name: "index_posts_on_scheduled_for"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "auth_token", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["auth_token"], name: "index_users_on_auth_token"
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "posts", "users", column: "approved_by_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "posts", "users", column: "declined_by_id"
end
