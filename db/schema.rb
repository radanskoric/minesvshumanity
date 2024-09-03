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

ActiveRecord::Schema[7.1].define(version: 2024_09_03_185810) do
  create_table "account_login_change_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "login", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_remember_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_verification_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "status", default: 1, null: false
    t.string "email", null: false
    t.string "password_hash"
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "boards", force: :cascade do |t|
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clicks", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "x", null: false
    t.integer "y", null: false
    t.datetime "created_at", null: false
    t.boolean "mark_as_mine", default: false, null: false
    t.index ["game_id"], name: "index_clicks_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.boolean "fair_start", default: false, null: false
    t.integer "match_id"
    t.index ["board_id"], name: "index_games_on_board_id"
    t.index ["match_id"], name: "index_games_on_match_id"
    t.index ["owner_id"], name: "index_games_on_owner_id"
    t.index ["status", "match_id"], name: "only_one_active_game_per_match", unique: true, where: "status = 0 AND match_id IS NOT NULL"
    t.check_constraint "owner_id IS NOT NULL OR match_id IS NOT NULL", name: "games_owner_or_match_id_must_be_set"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "owner_id"
    t.string "name"
    t.boolean "finished", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finished"], name: "only_one_public_match", unique: true, where: "NOT finished AND owner_id IS NULL"
    t.index ["owner_id"], name: "index_matches_on_owner_id"
  end

  create_table "mines", force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "x", null: false
    t.integer "y", null: false
    t.index ["board_id"], name: "index_mines_on_board_id"
  end

  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_remember_keys", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
  add_foreign_key "clicks", "games"
  add_foreign_key "games", "accounts", column: "owner_id"
  add_foreign_key "games", "boards"
  add_foreign_key "games", "matches"
  add_foreign_key "matches", "accounts", column: "owner_id"
  add_foreign_key "mines", "boards"
end
