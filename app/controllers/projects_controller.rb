class ProjectsController < ApplicationController
  respond_to :html, :json
  
  def index
    @projects = current_user.projects
  end
  
  def enqueue
    @project = Project.find_by!(id: params[:id])
    @project.enqueue!
    respond_with(@project)
  rescue AASM::InvalidTransition => e
    render nothing: true
  end
  
  def preferences
    @project = Project.find_by!(id: params[:id])
  end
end
