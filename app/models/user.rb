class User < ActiveRecord::Base
  include Authentication::ActiveRecordHelpers

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid

  has_many :projects, :dependent => :nullify
  
  def create_project(options)
    Project.create(options.reverse_merge({user_id: self.id }))
  end
  
end
