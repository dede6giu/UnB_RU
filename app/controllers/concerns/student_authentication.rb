module StudentAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_student
  end

  private

  # a sessão guarda a matrícula, que é a chave da conta e do estudante
  def require_student
    @student = Student.find_by(user: session[:student_id])
    redirect_to new_student_session_path, alert: "Faça login para continuar." unless @student
  end
end
