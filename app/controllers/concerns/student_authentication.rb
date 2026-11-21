# Exige o estudante logado nos controllers que incluem este módulo (portal, recarga, extrato).
module StudentAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_student
  end

  private

  ##
  # Carrega o estudante logado em `@student`; a sessão guarda a matrícula, que é a chave da conta e do
  # estudante.
  #
  # Não recebe argumentos nem retorna valor útil. Sem estudante na sessão, redireciona para o login do
  # estudante com "Faça login para continuar." e a ação do controller não roda.
  def require_student
    @student = Student.find_by(user: session[:student_id])
    redirect_to new_student_session_path, alert: "Faça login para continuar." unless @student
  end
end
