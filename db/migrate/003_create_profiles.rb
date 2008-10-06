class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :user_id
      t.integer :gender
      t.datetime :birthdate
      t.timestamps
    end

    add_index "profiles", "user_id"
  end

  def self.down
    drop_table :profiles
  end
end
