
ActiveRecord::Schema.define(version: 20191030142830) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activations", force: :cascade do |t|
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "parent_email"
    t.string   "child_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "token"
    t.string   "lang",               default: "en"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "super_admin",            default: false
    t.boolean  "is_client",              default: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "analytic_charts", force: :cascade do |t|
    t.string   "static_image_url"
    t.text     "static_data_uri"
    t.integer  "analytic_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "failed",           default: false
  end

  create_table "analytic_configs", force: :cascade do |t|
    t.date     "program_start"
    t.date     "program_end"
    t.date     "global_query_start"
    t.date     "global_query_end"
    t.text     "global_colors",             default: [], array: true
    t.hstore   "specific_colors",           default: {}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slack_channel"
    t.text     "email_list"
    t.string   "project_name"
    t.string   "project_logo_file_name"
    t.string   "project_logo_content_type"
    t.integer  "project_logo_file_size"
    t.datetime "project_logo_updated_at"
    t.string   "project_description"
  end

  create_table "analytics", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.text     "query"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "chart"
    t.boolean  "live",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chart_size"
    t.integer  "order",               default: 9999
    t.integer  "analytic_config_id"
    t.integer  "analytic_configs_id"
    t.boolean  "send_to_slack",       default: false
    t.boolean  "send_to_email",       default: false
    t.string   "static_image_url"
    t.text     "static_data_uri"
    t.string   "frequency"
    t.integer  "send_day"
    t.string   "chart_data_period"
    t.string   "slack_channel"
    t.string   "email_list"
    t.boolean  "chart_to_end_date",   default: false
    t.string   "chart_goal_line"
    t.boolean  "show_client",         default: false
  end

  add_index "analytics", ["analytic_configs_id"], name: "index_analytics_on_analytic_configs_id", using: :btree

  create_table "challenges", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title_fr"
    t.string   "description_fr"
    t.integer  "display_order"
    t.boolean  "soft_deleted",   default: false
  end

  create_table "child_auth_requests", force: :cascade do |t|
    t.string   "email"
    t.string   "lang"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sms"
    t.string   "from_name"
  end

  create_table "coaches", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_token"
    t.boolean  "banned",                      default: false
    t.boolean  "soft_banned",                 default: false
    t.boolean  "soft_deleted",                default: false
    t.string   "username"
    t.string   "email",                       default: "",                    null: false
    t.string   "encrypted_password",          default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",             default: 0,                     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "child_consent",               default: false
    t.boolean  "terms_conditions",            default: false
    t.boolean  "privacy_policy",              default: false
    t.boolean  "receive_promos",              default: false
    t.boolean  "sport_chek_promos",           default: false
    t.string   "city"
    t.string   "province"
    t.string   "lang",                        default: "ce"
    t.string   "email_change_token"
    t.string   "email_change_request"
    t.boolean  "child_reminder_sent",         default: false
    t.boolean  "is_uploader",                 default: false
    t.integer  "team_id"
    t.boolean  "receive_promos_email"
    t.boolean  "receive_email_notifications", default: true
    t.boolean  "tow_email_sent",              default: false
    t.boolean  "vote_nudge",                  default: false
    t.datetime "last_viewed_trophies",        default: '2017-08-28 15:08:27'
  end

  add_index "coaches", ["confirmation_token"], name: "index_coaches_on_confirmation_token", unique: true, using: :btree
  add_index "coaches", ["email"], name: "index_coaches_on_email", unique: true, using: :btree
  add_index "coaches", ["reset_password_token"], name: "index_coaches_on_reset_password_token", unique: true, using: :btree
  add_index "coaches", ["team_id"], name: "index_coaches_on_team_id", using: :btree
  add_index "coaches", ["unlock_token"], name: "index_coaches_on_unlock_token", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "earned_trophies", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "trophy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "progress",    default: 0
    t.boolean  "earned",      default: false
    t.datetime "earned_date"
  end

  create_table "entry_videos", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.text     "headline"
    t.text     "caption"
    t.string   "converted_thumb_url_large"
    t.boolean  "featured",                  default: false
    t.boolean  "hidden",                    default: false
    t.boolean  "soft_deleted",              default: false
    t.boolean  "flagged",                   default: false
    t.integer  "zencoder_job_id"
    t.string   "converted_clip_url"
    t.string   "converted_thumb_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",                  default: false
    t.text     "reason_for_flag"
  end

  add_index "entry_videos", ["user_id"], name: "index_entry_videos_on_user_id", using: :btree

  create_table "existing_teams", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "lang"
    t.string   "team_name"
    t.string   "team_postal_code"
    t.string   "team_arena"
    t.string   "team_club_level"
    t.string   "team_avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_token"
  end

  create_table "faq_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "display_order"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "name_fr"
  end

  create_table "faqs", force: :cascade do |t|
    t.text     "question"
    t.text     "answer"
    t.boolean  "soft_deleted",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
    t.string   "locales",         default: [],    array: true
    t.integer  "faq_category_id"
  end

  add_index "faqs", ["faq_category_id"], name: "index_faqs_on_faq_category_id", using: :btree

  create_table "inspirations", force: :cascade do |t|
    t.string   "description"
    t.string   "description_fr"
    t.integer  "display_order"
    t.integer  "challenge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "title_fr"
  end

  add_index "inspirations", ["challenge_id"], name: "index_inspirations_on_challenge_id", using: :btree

  create_table "interstitial_posts", force: :cascade do |t|
    t.integer  "display_order",             default: 0
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "link"
    t.boolean  "live",                      default: false
    t.string   "sticker"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zencoder_job_id"
    t.string   "converted_thumb_url_large"
    t.string   "converted_clip_url"
    t.string   "converted_thumb_url"
    t.string   "headline"
    t.text     "caption"
    t.string   "feeds",                     default: [],    array: true
    t.string   "lang"
    t.string   "btn_text"
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ms_elapsed", default: 0
    t.text     "text"
    t.string   "icon"
  end

  add_index "likes", ["post_id"], name: "index_likes_on_post_id", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "message_views", force: :cascade do |t|
    t.integer  "coach_id"
    t.integer  "announcement_id"
    t.integer  "seen_count",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "headline"
    t.text     "headline_french"
    t.text     "body"
    t.text     "body_french"
    t.datetime "date_start"
    t.datetime "date_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "viewed_by",       default: [], array: true
    t.string   "link"
  end

  create_table "parents", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_token"
    t.boolean  "banned",               default: false
    t.boolean  "soft_banned",          default: false
    t.boolean  "soft_deleted",         default: false
    t.string   "username"
    t.boolean  "child_consent",        default: false
    t.boolean  "terms_conditions",     default: false
    t.boolean  "privacy_policy",       default: false
    t.boolean  "receive_promos",       default: false
    t.boolean  "sport_chek_promos",    default: false
    t.string   "city"
    t.string   "province"
    t.string   "lang",                 default: "en"
    t.string   "email_change_token"
    t.string   "email_change_request"
    t.boolean  "child_reminder_sent",  default: false
    t.boolean  "is_uploader",          default: false
  end

  create_table "postal_codes", force: :cascade do |t|
    t.string   "code"
    t.string   "program"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "team_id"
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.text     "headline"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                  default: false
    t.boolean  "hidden",                    default: false
    t.boolean  "soft_deleted",              default: false
    t.integer  "zencoder_job_id"
    t.string   "converted_clip_url"
    t.string   "converted_thumb_url"
    t.integer  "like_count",                default: 0
    t.string   "converted_thumb_url_large"
    t.boolean  "approved",                  default: false
    t.boolean  "highlight",                 default: false
    t.integer  "highlight_order",           default: 0
    t.string   "sticker"
    t.integer  "like_level",                default: 0
    t.integer  "width",                     default: 0
    t.integer  "height",                    default: 0
    t.integer  "challenge_id"
    t.string   "s3_path"
    t.boolean  "denied",                    default: false
    t.datetime "status_changed_at"
    t.integer  "coach_id"
    t.integer  "quality_score",             default: 2,     null: false
    t.integer  "voting_week"
    t.boolean  "vote_winner",               default: false
    t.boolean  "vote_loser",                default: false
    t.text     "sticker_json"
    t.text     "denied_reason"
  end

  add_index "posts", ["challenge_id"], name: "index_posts_on_challenge_id", using: :btree
  add_index "posts", ["coach_id"], name: "index_posts_on_coach_id", using: :btree
  add_index "posts", ["team_id"], name: "index_posts_on_team_id", using: :btree

  create_table "reminder_emails", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lang",       default: "en"
    t.string   "sms"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "renewal_token"
    t.datetime "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coach_id"
  end

  create_table "site_configs", force: :cascade do |t|
    t.string  "name"
    t.string  "program_url"
    t.string  "site_status"
    t.boolean "accepting_contest_entries", default: false
  end

  create_table "static_pages", force: :cascade do |t|
    t.string   "category"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text_french"
  end

  create_table "stickers", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.boolean  "animated_sprite",    default: false
    t.integer  "trophy_id"
    t.boolean  "starter",            default: false
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "auth_token"
    t.boolean  "banned",                    default: false
    t.boolean  "soft_banned",               default: false
    t.boolean  "soft_deleted",              default: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "entry_video_reminder_sent", default: false
    t.string   "name"
    t.string   "arena"
    t.string   "token"
    t.string   "program"
    t.string   "slug"
    t.string   "postalcode"
    t.string   "clublevel"
    t.integer  "frame_level",               default: 0
    t.integer  "star_level",                default: 0
    t.integer  "activity_score"
    t.date     "winner_week_of"
    t.boolean  "chapter_complete_email",    default: false
    t.boolean  "chapter_nudge",             default: false
    t.boolean  "extra_credit_nudge",        default: false
    t.integer  "total_activity_score"
    t.boolean  "contender",                 default: false
    t.integer  "day_streak",                default: 0
    t.integer  "week_streak",               default: 0
    t.string   "existing_avatar_url"
    t.boolean  "chapter_one_nudge",         default: false
    t.boolean  "chapter_three_nudge",       default: false
    t.boolean  "entered_email_sent",        default: false
  end

  add_index "teams", ["reset_password_token"], name: "index_teams_on_reset_password_token", unique: true, using: :btree

  create_table "trophies", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "chapter_number"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "mystery",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tier",                          default: 1
    t.integer  "max_tier",                      default: 1
    t.integer  "number_required",               default: 1
    t.integer  "display_order",                 default: 0
    t.string   "initial_trophy_file_name"
    t.string   "initial_trophy_content_type"
    t.integer  "initial_trophy_file_size"
    t.datetime "initial_trophy_updated_at"
    t.string   "completed_trophy_file_name"
    t.string   "completed_trophy_content_type"
    t.integer  "completed_trophy_file_size"
    t.datetime "completed_trophy_updated_at"
    t.boolean  "post_upload_total",             default: false
    t.string   "title_fr"
    t.text     "description_fr"
    t.string   "initial_trophy_default"
    t.string   "completed_trophy_default"
    t.text     "mystery_description"
    t.text     "mystery_description_fr"
    t.string   "subject_line",                  default: ""
    t.string   "subject_line_fr",               default: ""
  end

  create_table "user_flags", force: :cascade do |t|
    t.integer  "user_flagged_id"
    t.integer  "user_flagger_id"
    t.integer  "post_id"
    t.boolean  "cleared",         default: false
    t.integer  "cleared_by"
    t.datetime "cleared_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_type"
    t.integer  "entry_video_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "auth_token"
    t.boolean  "banned",                    default: false
    t.boolean  "soft_banned",               default: false
    t.boolean  "soft_deleted",              default: false
    t.string   "username"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "parent_id"
    t.date     "birthday"
    t.string   "sports",                    default: [],                 array: true
    t.string   "province"
    t.string   "gender"
    t.integer  "age",                       default: 0
    t.boolean  "entry_video_reminder_sent", default: false
  end

  add_index "users", ["parent_id"], name: "index_users_on_parent_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "week"
    t.integer  "post_id"
    t.integer  "coach_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "votes", ["coach_id", "week"], name: "index_votes_on_coach_id_and_week", unique: true, using: :btree
  add_index "votes", ["coach_id"], name: "index_votes_on_coach_id", using: :btree
  add_index "votes", ["post_id"], name: "index_votes_on_post_id", using: :btree

  add_foreign_key "analytics", "analytic_configs"
  add_foreign_key "coaches", "teams"
  add_foreign_key "faqs", "faq_categories"
  add_foreign_key "posts", "challenges"
  add_foreign_key "stickers", "trophies"
  add_foreign_key "votes", "coaches"
  add_foreign_key "votes", "posts"
end