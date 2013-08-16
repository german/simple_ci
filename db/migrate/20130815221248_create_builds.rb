class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.text :output
      t.integer :failed_tests
      t.integer :pending_tests
      t.integer :succeeded_tests
      t.integer :project_id, null: false
      t.float :duration
      t.string :aasm_state
      t.timestamps
    end
    
    add_index :builds, :project_id
  end
end
