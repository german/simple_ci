class AddNewFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :output, :text
    add_column :projects, :failed_tests, :integer
    add_column :projects, :pending_tests, :integer
    add_column :projects, :succeeded_tests, :integer
  end
end
