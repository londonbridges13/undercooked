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

ActiveRecord::Schema.define(version: 20170601141607) do

  create_table "actions", force: :cascade do |t|
    t.string   "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "actions_instructions", id: false, force: :cascade do |t|
    t.integer "action_id",      null: false
    t.integer "instruction_id", null: false
  end

  add_index "actions_instructions", ["action_id", "instruction_id"], name: "index_actions_instructions_on_action_id_and_instruction_id"
  add_index "actions_instructions", ["instruction_id", "action_id"], name: "index_actions_instructions_on_instruction_id_and_action_id"

  create_table "articles", force: :cascade do |t|
    t.string   "title"
    t.string   "article_url"
    t.string   "article_image_url"
    t.text     "desc"
    t.string   "resource_type"
    t.datetime "article_date"
    t.boolean  "publish_it"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "resource_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "display_topic"
  end

  add_index "articles", ["resource_id"], name: "index_articles_on_resource_id"

  create_table "articles_tags", id: false, force: :cascade do |t|
    t.integer "tag_id",     null: false
    t.integer "article_id", null: false
  end

  add_index "articles_tags", ["article_id", "tag_id"], name: "index_articles_tags_on_article_id_and_tag_id"
  add_index "articles_tags", ["tag_id", "article_id"], name: "index_articles_tags_on_tag_id_and_article_id"

  create_table "articles_topics", id: false, force: :cascade do |t|
    t.integer "topic_id",   null: false
    t.integer "article_id", null: false
  end

  add_index "articles_topics", ["article_id", "topic_id"], name: "index_articles_topics_on_article_id_and_topic_id"
  add_index "articles_topics", ["topic_id", "article_id"], name: "index_articles_topics_on_topic_id_and_article_id"

  create_table "articles_users", id: false, force: :cascade do |t|
    t.integer "user_id",    null: false
    t.integer "article_id", null: false
  end

  add_index "articles_users", ["article_id", "user_id"], name: "index_articles_users_on_article_id_and_user_id"
  add_index "articles_users", ["user_id", "article_id"], name: "index_articles_users_on_user_id_and_article_id"

  create_table "auto_publishings", force: :cascade do |t|
    t.string   "reasons"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "suggestion_id"
  end

  add_index "auto_publishings", ["suggestion_id"], name: "index_auto_publishings_on_suggestion_id"

  create_table "content_managements", force: :cascade do |t|
    t.string   "last_new_article_grab_date"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string   "message"
    t.string   "suggestion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id"

  create_table "ingredients", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instructions", force: :cascade do |t|
    t.string   "instruction"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "recipe_id"
  end

  add_index "instructions", ["recipe_id"], name: "index_instructions_on_recipe_id"

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                               null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                          null: false
    t.string   "scopes"
    t.string   "previous_refresh_token", default: "", null: false
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.string   "product_url"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "description"
  end

  create_table "products_tags", id: false, force: :cascade do |t|
    t.integer "tag_id",     null: false
    t.integer "product_id", null: false
  end

  add_index "products_tags", ["product_id", "tag_id"], name: "index_products_tags_on_product_id_and_tag_id"
  add_index "products_tags", ["tag_id", "product_id"], name: "index_products_tags_on_tag_id_and_product_id"

  create_table "products_topics", id: false, force: :cascade do |t|
    t.integer "topic_id",   null: false
    t.integer "product_id", null: false
  end

  add_index "products_topics", ["product_id", "topic_id"], name: "index_products_topics_on_product_id_and_topic_id"
  add_index "products_topics", ["topic_id", "product_id"], name: "index_products_topics_on_topic_id_and_product_id"

  create_table "recipe_ingredients", force: :cascade do |t|
    t.float    "amount"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "ingredient_id"
    t.integer  "recipe_id"
    t.string   "unit"
  end

  add_index "recipe_ingredients", ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
  add_index "recipe_ingredients", ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"

  create_table "recipes", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "author"
    t.string   "serving_size"
    t.float    "prep_time"
    t.float    "cooktime"
    t.float    "total_time"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "article_id"
  end

  add_index "recipes", ["article_id"], name: "index_recipes_on_article_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.boolean  "is_channel"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id", "is_channel"], name: "index_relationships_on_following", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"
  add_index "relationships", ["is_channel"], name: "index_relationships_on_is_channel"

  create_table "resources", force: :cascade do |t|
    t.string   "title"
    t.string   "resource_url"
    t.string   "resource_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "about_url"
    t.text     "desc"
  end

  create_table "resources_tags", id: false, force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "tag_id",      null: false
  end

  add_index "resources_tags", ["resource_id", "tag_id"], name: "index_resources_tags_on_resource_id_and_tag_id"
  add_index "resources_tags", ["tag_id", "resource_id"], name: "index_resources_tags_on_tag_id_and_resource_id"

  create_table "resources_topics", id: false, force: :cascade do |t|
    t.integer "topic_id",    null: false
    t.integer "resource_id", null: false
  end

  add_index "resources_topics", ["resource_id", "topic_id"], name: "index_resources_topics_on_resource_id_and_topic_id"
  add_index "resources_topics", ["topic_id", "resource_id"], name: "index_resources_topics_on_topic_id_and_resource_id"

  create_table "suggestions", force: :cascade do |t|
    t.boolean  "rejected"
    t.string   "reason"
    t.string   "evidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "topic_id"
    t.integer  "article_id"
  end

  add_index "suggestions", ["article_id"], name: "index_suggestions_on_article_id"
  add_index "suggestions", ["topic_id"], name: "index_suggestions_on_topic_id"

  create_table "tags", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags_topics", id: false, force: :cascade do |t|
    t.integer "tag_id",   null: false
    t.integer "topic_id", null: false
  end

  add_index "tags_topics", ["tag_id", "topic_id"], name: "index_tags_topics_on_tag_id_and_topic_id"
  add_index "tags_topics", ["topic_id", "tag_id"], name: "index_tags_topics_on_topic_id_and_tag_id"

  create_table "timers", force: :cascade do |t|
    t.integer  "seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "topic_id"
  end

  add_index "timers", ["topic_id"], name: "index_timers_on_topic_id"
  add_index "timers", ["user_id"], name: "index_timers_on_user_id"

  create_table "topics", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "taglist",            default: "--- []\n"
    t.string   "keywords",           default: "--- []\n"
    t.string   "auto_proofs",        default: "{}"
  end

  create_table "topics_users", id: false, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "topics_users", ["topic_id", "user_id"], name: "index_topics_users_on_topic_id_and_user_id"
  add_index "topics_users", ["user_id", "topic_id"], name: "index_topics_users_on_user_id_and_topic_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "access_token"
    t.boolean  "login_with_facebook"
    t.string   "facebook_id"
    t.string   "picture_url"
    t.integer  "topic_order",            default: 0
    t.integer  "launch_count"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
