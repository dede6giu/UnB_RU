# Controller para a autenticação de Admin.
class AdminSessionsController < ApplicationController
  include Authentication
  before_action :require_no_admin, only: %i[new create]

  ##
  # GET /admin/login
  #
  # Chamado durante o processo, mas não realiza nada.
  def new
  end

  ##
  # POST /admin/login
  #
  # Verifica as credenciais passadas como parâmetro do formulário,
  # e então compara-as com a database.
  #
  # Caso exista algum Admin com as mesmas credenciais, cria-se uma nova sessão.
  # O administrador é redirecionado para RestaurantsController#index.
  #
  # Caso as credenciais não sejam válidas, avisa que os valores não foram
  # escritos corretamente. O usuário retorna para AdminSessionsController#new.
  #
  # Caso as credenciais são válidas mas não tem correspondência, avisa que
  # algo está errado, mas não *o quê* (questões de segurança).
  # O usuário retorna para AdminSessionsController#new.
  def create
    account_values = admin_params
    if authenticate_admin(account_values)
      session[:admin_id] = account_values[:user]
      redirect_to restaurants_path, notice: "Sucesso na autenticação."
    else
      failed_login(account_values)
    end
  end

  ##
  # DELETE /admin/login
  #
  # Remove o registro de sessão e, portanto, a autenticação como
  # administrador.
  #
  # Redireciona o usuário para a página de login de admins.
  def destroy
    session.delete(:admin_id)
    redirect_to new_admin_session_path, notice: "Você saiu da conta."
  end

  private

  def admin_params
    params.require(:admin).permit(:user, :password)
  end

  def valid_userid(userid)
    userid =~ Account.user_format_for("admin")
  end

  def authenticate_admin(account_values)
    admin = Account.find_by(user: account_values[:user], role: "admin")
    if admin
      admin.authenticate(account_values[:password])
    else
      false
    end
  end

  def failed_login(account_values)
    if valid_userid(account_values[:user])
      flash.now[:alert] = "Matrícula ou senha incorretas."
    else
      flash.now[:alert] = "Matrícula inválida."
    end
    render :new, status: :unprocessable_entity
  end
end
