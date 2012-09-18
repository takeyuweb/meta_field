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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120914063447) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "books", :force => true do |t|
    t.string   "name"
    t.integer  "author_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "books", ["author_id"], :name => "index_books_on_author_id"

  create_table "car_cars", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "meta_field_metas", :force => true do |t|
    t.integer  "obj_id"
    t.string   "obj_type"
    t.string   "basename"
    t.string   "string"
    t.text     "text"
    t.integer  "integer"
    t.float    "float"
    t.decimal  "decimal"
    t.datetime "datetime"
    t.datetime "timestamp"
    t.time     "time"
    t.date     "date"
    t.binary   "binary"
    t.boolean  "boolean"
    t.string   "indexed_string"
    t.integer  "indexed_integer"
    t.float    "indexed_float"
    t.decimal  "indexed_decimal"
    t.datetime "indexed_datetime"
    t.datetime "indexed_timestamp"
    t.time     "indexed_time"
    t.date     "indexed_date"
    t.boolean  "indexed_boolean"
  end

  add_index "meta_field_metas", ["indexed_boolean"], :name => "index_meta_field_metas_on_indexed_boolean"
  add_index "meta_field_metas", ["indexed_date"], :name => "index_meta_field_metas_on_indexed_date"
  add_index "meta_field_metas", ["indexed_datetime"], :name => "index_meta_field_metas_on_indexed_datetime"
  add_index "meta_field_metas", ["indexed_decimal"], :name => "index_meta_field_metas_on_indexed_decimal"
  add_index "meta_field_metas", ["indexed_float"], :name => "index_meta_field_metas_on_indexed_float"
  add_index "meta_field_metas", ["indexed_integer"], :name => "index_meta_field_metas_on_indexed_integer"
  add_index "meta_field_metas", ["indexed_string"], :name => "index_meta_field_metas_on_indexed_string"
  add_index "meta_field_metas", ["indexed_time"], :name => "index_meta_field_metas_on_indexed_time"
  add_index "meta_field_metas", ["indexed_timestamp"], :name => "index_meta_field_metas_on_indexed_timestamp"
  add_index "meta_field_metas", ["obj_id", "obj_type", "basename"], :name => "index_meta_field_metas_on_obj_id_and_obj_type_and_basename"
  add_index "meta_field_metas", ["obj_id", "obj_type"], :name => "index_meta_field_metas_on_obj_id_and_obj_type"

end
