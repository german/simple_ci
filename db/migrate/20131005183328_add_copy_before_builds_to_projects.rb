class AddCopyBeforeBuildsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :copy_before_builds, :boolean, default: false
  end
end
