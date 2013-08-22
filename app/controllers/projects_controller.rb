class ProjectsController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!
  
  def index
    @projects = current_user.projects
  end

  def update
    @project = current_user.projects.find_by!(id: params[:id])
    @project.update_attributes!(project_params)
    redirect_to projects_path #@project
  end
    
  def enqueue
    @project = current_user.projects.find_by!(id: params[:id])
    @project.enqueue!
    respond_to do |format|
      format.json { render json: @project }
    end
  rescue AASM::InvalidTransition => e
    @project.fail!
    render nothing: true
  end

  def preferences
    @project = Project.find_by!(id: params[:id])
  end
  
private
  def project_params
    params.require(:project).permit(:name, :path_to_rails_root)
  end
end
