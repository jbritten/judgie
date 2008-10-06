class MergeProfileIntoUser < ActiveRecord::Migration
  def self.up
    add_column(:users, "gender", :integer)
    add_column(:users, "birthdate", :datetime)
    User.reset_column_information
    
    User.find(:all).each do |user|
      profile = Profile.find_by_user_id(user.id)
      user.update_attribute_with_validation_skipping(:gender, profile.gender)
      user.update_attribute_with_validation_skipping(:birthdate, profile.birthdate)
    end
    
    remove_index :profiles, "user_id"
    drop_table :profiles
  end

  def self.down
    create_table :profiles do |t|
      t.integer :user_id
      t.integer :gender
      t.datetime :birthdate
      t.timestamps
    end

    add_index "profiles", "user_id"

    User.find(:all).each do |user|
      Profile.create(:user_id => user.id, :gender => user.gender, :birthdate => user.birthdate)
    end

    remove_column(:users, "birthdate")
    remove_column(:users, "gender")
  end
end
