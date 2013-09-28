class BuildsController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!
  
  def details
    @build = current_user.projects.find(params[:project_id]).builds.find(params[:id])
  end
end