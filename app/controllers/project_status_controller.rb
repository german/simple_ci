class ProjectStatusController < ActionController::Metal
  def check
    project = Project.find params[:id]
    self.response_body = "{status: #{project.aasm_state}}"
  end
end