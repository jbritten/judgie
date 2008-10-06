class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :user_id
      t.string  :the_question
      t.boolean :anonymous, :default => false
      t.integer :yes_count, :default => 0
      t.integer :no_count, :default => 0
      t.integer :replies_count, :default => 0
      t.timestamps
    end

    add_index "questions", "user_id"
  end

  def self.down
    drop_table :questions
  end
end
