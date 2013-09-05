class Project < ActiveRecord::Base  
  belongs_to :user
  has_many :builds
  
  validates :name, :path_to_rails_root, presence: true
  validates :path_to_rails_root, rails_project: true
  
  def state
    self.builds.order('updated_at DESC').to_a.try(:first).try(:aasm_state)
  end
end