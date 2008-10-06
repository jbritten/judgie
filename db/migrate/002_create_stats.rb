class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.integer :user_id
      t.integer :question_count, :default => 0
      t.integer :reply_count, :default => 0
      t.timestamps
    end

    add_index "stats", "user_id"
  end

  def self.down
    drop_table :stats
  end
end
