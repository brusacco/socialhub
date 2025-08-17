# frozen_string_literal: true

class CreateSocialAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :social_accounts do |t|
      t.references :profile, null: false, foreign_key: true
      t.integer :network, null: false, default: 0 # enum: ig=0, fb=1, tiktok=2
      t.string :uid
      t.string :username
      t.string :display_name
      t.json :data
      t.integer :followers, null: false, default: 0
      t.integer :following, null: false, default: 0

      t.timestamps
    end
  end
end
