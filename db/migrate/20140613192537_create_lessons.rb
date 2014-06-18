class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :title
    	t.integer :difficulty_level
    	t.integer :language_id
    	
      t.timestamps
    end
  end
end
