class CreateReplies < ActiveRecord::Migration
  def self.up
    create_table :replies do |t|
      t.integer :user_id
      t.integer :question_id
      t.boolean :yes
      t.timestamps
    end

    add_index "replies", ["user_id", "question_id"]
  end

  def self.down
    drop_table :replies
  end
end
