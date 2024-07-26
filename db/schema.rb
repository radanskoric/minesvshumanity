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

ActiveRecord::Schema[7.1].define(version: 2024_07_26_121713) do
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
    t.index ["game_id"], name: "index_clicks_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_games_on_board_id"
    t.index ["status"], name: "index_games_on_status", unique: true, where: "status = 0"
  end

  create_table "mines", force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "x", null: false
    t.integer "y", null: false
    t.index ["board_id"], name: "index_mines_on_board_id"
  end

  add_foreign_key "clicks", "games"
  add_foreign_key "games", "boards"
  add_foreign_key "mines", "boards"
end
