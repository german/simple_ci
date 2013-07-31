class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :path_to_rails_root
      
      t.string :aasm_state
      t.integer :user_id
      
      t.timestamps
    end
    
    add_index :projects, :user_id
  end
end
