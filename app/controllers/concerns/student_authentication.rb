module StudentAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_student
  end

  private

  # A sessão guarda o id da Account; o saldo está no Student ligado a ela.
  def require_student
    @student = Student.find_by(account_id: session[:student_id])
    redirect_to new_student_session_path, alert: "Faça login para continuar." unless @student
  end
end
