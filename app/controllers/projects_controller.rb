class ProjectsController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!
  
  def index
    @projects = current_user.projects
  end

  def update
    @project = current_user.projects.find_by!(id: params[:id])
    if @project.update_attributes(project_params)
      redirect_to projects_path, :notice => "Project sucessfully saved" #@project
    else
      redirect_to :back, :notice => "There were errors while saving project"
    end
  end
    
  def enqueue
    @project = current_user.projects.find_by!(id: params[:id])
    @project.builds.create!.enqueue!
    respond_to do |format|
      format.json { render json: @project }
      format.html { redirect_to projects_path }
    end
  rescue AASM::InvalidTransition => e
    @project.fail!
    render nothing: true
  end

  def preferences
    @project = Project.find_by!(id: params[:id])
  end
  
  def check_status
    project = Project.find params[:id]
    last_successfull_build = project.builds.where(['aasm_state = ?', 'success']).order('updated_at ASC').last
    render json: {status: project.state, reference_duration: last_successfull_build.try(:duration)}
  end
private
  def project_params
    params.require(:project).permit(:name, :path_to_rails_root)
  end
end
