class ProjectStatusController < ActionController::Metal
  def check
    project = Project.find params[:id]
    self.response_body = "{status: #{project.state}}"
  end
end