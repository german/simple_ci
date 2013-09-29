class Project < ActiveRecord::Base
  attr_accessible :user_id, :name, :path_to_rails_root, :aasm_state, :run_bundle_before_builds, :branch
  
  belongs_to :user
  has_many :builds
  
  validates :name, :path_to_rails_root, presence: true
  validates :path_to_rails_root, rails_project: true
  
  def state
    self.builds.order('updated_at DESC').to_a.try(:first).try(:aasm_state)
  end
end