class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_admin, :current_operator, :current_student

  private

  def current_admin
    @current_admin ||= Account.find_by(user: session[:admin_id], role: "admin")
  end

  def current_operator
    @current_operator ||= Account.find_by(user: session[:operator_id], role: "operator")
  end

  def current_student
    @current_student ||= Account.find_by(user: session[:student_id], role: "student")&.student
  end
end
