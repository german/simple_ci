class AddMorePropertiesToProjectsTable < ActiveRecord::Migration
  def change
    add_column :projects, :run_bundle_before_builds, :boolean, default: false
    add_column :projects, :branch, :string, default: 'master'
  end
end
