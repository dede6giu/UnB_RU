# Impede que quem já está logado veja as telas de entrar e manda cada um para a sua tela inicial.
#
# O módulo só define os filtros. Cada controller de sessão inclui o módulo e escolhe o
# próprio filtro com +before_action+, limitado às actions de entrar (assim o +destroy+,
# que faz o logout, nunca é bloqueado).
module Authentication
  extend ActiveSupport::Concern

  private

  ##
  # Filtro das telas de login e cadastro do estudante.
  #
  # Não recebe argumentos nem retorna valor útil. Se já houver um estudante na sessão,
  # redireciona para StudentPortalController#show e a action do controller não roda.
  def require_no_student
    redirect_to student_portal_path if current_student
  end

  ##
  # Filtro da tela de login do admin.
  #
  # Não recebe argumentos nem retorna valor útil. Se já houver um admin na sessão,
  # redireciona para RestaurantsController#index e a action do controller não roda.
  def require_no_admin
    redirect_to restaurants_path if current_admin
  end

  ##
  # Filtro da tela de login do operador.
  #
  # Não recebe argumentos nem retorna valor útil. Se já houver um operador na sessão,
  # redireciona para AccessPointsController#new e a action do controller não roda.
  def require_no_operator
    redirect_to new_access_point_path if current_operator
  end
end
