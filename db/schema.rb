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

ActiveRecord::Schema.define(version: 20171007232041) do

  create_table "access_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.string "action"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["resource_type", "resource_id"], name: "index_access_logs_on_resource_type_and_resource_id"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "broadcast_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "content"
    t.datetime "originated_at"
    t.bigint "broadcast_municipality_id"
    t.text "translation"
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deprecated", default: false
    t.bigint "user_id"
    t.index ["broadcast_municipality_id"], name: "index_broadcast_items_on_broadcast_municipality_id"
    t.index ["user_id"], name: "index_broadcast_items_on_user_id"
  end

  create_table "broadcast_municipalities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "case_notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "rescue_request_id"
    t.bigint "user_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "medical"
    t.index ["rescue_request_id"], name: "index_case_notes_on_rescue_request_id"
    t.index ["user_id"], name: "index_case_notes_on_user_id"
  end

  create_table "contact_attempts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "rescue_request_id"
    t.string "medium"
    t.string "outcome"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rescue_request_id"], name: "index_contact_attempts_on_rescue_request_id"
    t.index ["user_id"], name: "index_contact_attempts_on_user_id"
  end

  create_table "dedupe_reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "rescue_request_id"
    t.string "outcome"
    t.bigint "user_id"
    t.bigint "dupe_of_id"
    t.integer "suggested_duplicates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dupe_of_id"], name: "index_dedupe_reviews_on_dupe_of_id"
    t.index ["rescue_request_id"], name: "index_dedupe_reviews_on_rescue_request_id"
    t.index ["user_id"], name: "index_dedupe_reviews_on_user_id"
  end

  create_table "disasters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "medical_conditions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "severity"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medical_conditions_rescue_requests", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "medical_condition_id", null: false
    t.bigint "rescue_request_id", null: false
  end

  create_table "medical_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.string "created_at"
    t.string "updated_at"
  end

  create_table "request_priorities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rescue_request_id"
    t.index ["rescue_request_id"], name: "index_request_priorities_on_rescue_request_id"
  end

  create_table "request_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rescue_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal "lat", precision: 20, scale: 15
    t.decimal "long", precision: 20, scale: 15
    t.integer "incident_number"
    t.string "name"
    t.string "city"
    t.string "country"
    t.string "zip_code"
    t.string "twitter"
    t.string "phone"
    t.string "email"
    t.integer "people_count"
    t.text "medical_details"
    t.text "extra_details"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "disaster_id"
    t.string "street_address"
    t.integer "apt_no"
    t.bigint "request_status_id"
    t.string "media"
    t.bigint "medical_status_id"
    t.string "chart_code"
    t.integer "dupe_of"
    t.boolean "spam"
    t.integer "assignee_id"
    t.index ["disaster_id"], name: "index_rescue_requests_on_disaster_id"
    t.index ["medical_status_id"], name: "index_rescue_requests_on_medical_status_id"
    t.index ["request_status_id"], name: "index_rescue_requests_on_request_status_id"
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "spam_reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "rescue_request_id"
    t.string "outcome"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rescue_request_id"], name: "index_spam_reviews_on_rescue_request_id"
    t.index ["user_id"], name: "index_spam_reviews_on_user_id"
  end

  create_table "suggested_edits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "resource_type"
    t.bigint "resource_id"
    t.bigint "user_id"
    t.string "result"
    t.integer "reviewed_by_id"
    t.text "new_values"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "old_values"
    t.datetime "reviewed_at"
    t.index ["resource_type", "resource_id"], name: "index_suggested_edits_on_resource_type_and_resource_id"
    t.index ["user_id"], name: "index_suggested_edits_on_user_id"
  end

  create_table "user_authorizations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "resource_type"
    t.bigint "resource_id"
    t.bigint "user_id"
    t.integer "granted_by_id"
    t.string "valid_on"
    t.text "reason"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_user_authorizations_on_resource_type_and_resource_id"
    t.index ["user_id"], name: "index_user_authorizations_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "access_logs", "users"
  add_foreign_key "broadcast_items", "broadcast_municipalities"
  add_foreign_key "broadcast_items", "users"
  add_foreign_key "case_notes", "rescue_requests"
  add_foreign_key "case_notes", "users"
  add_foreign_key "contact_attempts", "rescue_requests"
  add_foreign_key "contact_attempts", "users"
  add_foreign_key "dedupe_reviews", "rescue_requests"
  add_foreign_key "dedupe_reviews", "users"
  add_foreign_key "request_priorities", "rescue_requests"
  add_foreign_key "rescue_requests", "disasters"
  add_foreign_key "rescue_requests", "medical_statuses"
  add_foreign_key "rescue_requests", "request_statuses"
  add_foreign_key "spam_reviews", "rescue_requests"
  add_foreign_key "spam_reviews", "users"
  add_foreign_key "suggested_edits", "users"
  add_foreign_key "user_authorizations", "users"
end
