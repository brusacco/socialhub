class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.string  :name, null: false                   # display/canonical name
      t.string  :slug, null: false                   # stable identifier for URLs
      t.integer :profile_type, null: false, default: 0       # enum: person=0, organization=1
      t.timestamps
    end
    add_index :profiles, :slug, unique: true
    add_index :profiles, :name
    add_index :profiles, :profile_type
  end
end
