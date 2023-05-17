class CreatePolls < ActiveRecord::Migration[6.1]
  def change

    create_table :polls do |t|
      t.string "status", default: "0"
      t.string "poll_type", default: "0"
      t.string "slug"
      t.string "title"
      t.text "description"
      t.string "region_id"
      t.string "cover_photo_id"
      t.string "cover_photo_content_type"
      t.jsonb "cover_photo_data"

      t.timestamps
      t.index ["slug"], name: "index_polls_on_slug"
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :poll_graetzls do |t|
      t.references :poll, index: true, foreign_key: { on_delete: :cascade }
      t.references :graetzl, index: true, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    create_table :poll_questions do |t|
      t.string "option_type", default: "0"
      t.string "title"
      t.text "description"
      t.boolean "required", default: true

      t.timestamps
      t.references :poll, index: true, foreign_key: { on_delete: :cascade }
    end

    create_table :poll_options do |t|
      t.string "title"

      t.timestamps
      t.references :poll_question, index: true, foreign_key: { on_delete: :cascade }
    end

    create_table :poll_users do |t|
      t.text "answer"

      t.references :poll, index: true, foreign_key: { on_delete: :cascade }
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
      t.timestamps
    end

    create_table :poll_user_answers do |t|
      t.text "answer"

      t.references :poll_question, index: true, foreign_key: { on_delete: :cascade }
      t.references :poll_option, index: true, foreign_key: { on_delete: :cascade }
      t.references :poll_user, foreign_key: { on_delete: :cascade }, index: true
      t.timestamps
    end

    add_reference :meetings, :poll, foreign_key: { on_delete: :nullify },  index: true
    add_index :polls, :region_id

  end
end
