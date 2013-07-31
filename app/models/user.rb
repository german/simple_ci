class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :projects, :dependent => :nullify
  
  def create_project(options)
    Project.create(options.reverse_merge({user_id: self.id }))
  end
  
end
