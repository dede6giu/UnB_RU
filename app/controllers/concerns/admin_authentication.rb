# Exige o admin logado nos controllers que incluem este módulo.
module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  ##
  # Filtro das telas do admin.
  #
  # Não recebe argumentos nem retorna valor útil. Sem admin na sessão, redireciona para o login do admin
  # com "Faça login para continuar." e a action do controller não roda.
  def require_admin
    redirect_to new_admin_session_path, alert: "Faça login para continuar." unless session[:admin_id].present?
  end
end
