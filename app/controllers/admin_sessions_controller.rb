class AdminSessionsController < ApplicationController
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
    admin_params = params.require(:admin).permit(:user, :password)
    if admin_params[:user] !~ Account.user_format_for("admin")
      flash.now[:alert] = "Matrícula inválida."
      render :new, status: :unprocessable_entity
      return
    end
    admin = Account.find_by(user: admin_params[:user], role: "admin")
    if admin && admin.authenticate(admin_params[:password])
      session[:admin_id] = admin.id
      redirect_to restaurants_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
    end
  end
end
