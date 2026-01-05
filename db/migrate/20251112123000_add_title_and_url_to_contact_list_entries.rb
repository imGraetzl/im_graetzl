# frozen_string_literal: true

class AddTitleAndUrlToContactListEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :contact_list_entries, :title, :string
    add_column :contact_list_entries, :url, :string
  end
end
