# Controller para a autenticação de Operator.
class OperatorSessionsController < ApplicationController
  ##
  # GET /operator/login
  #
  # Chamado durante o processo, mas não realiza nada.
  def new
  end

  ##
  # POST /operator/login
  #
  # Verifica as credenciais passadas como parâmetro do formulário,
  # e então compara-as com a database.
  #
  # Caso exista algum Operator com as mesmas credenciais, cria-se uma nova sessão.
  # O operador é redirecionado para AccessPointsController#show.
  #
  # Caso as credenciais não sejam válidas, avisa que os valores não foram
  # escritos corretamente. O usuário retorna para OperatorSessionsController#new.
  #
  # Caso as credenciais são válidas mas não tem correspondência, avisa que
  # algo está errado, mas não *o quê* (questões de segurança).
  # O usuário retorna para OperatorSessionsController#new.
  def create
    operator_params = params.require(:operator).permit(:user, :password)
    if operator_params[:user] !~ Account.user_format_for("operator")
      flash.now[:alert] = "Matrícula inválida."
      render :new, status: :unprocessable_entity
      return
    end
    operator = Account.find_by(user: operator_params[:user], role: "operator")
    if operator && operator.authenticate(operator_params[:password])
      session[:operator_id] = operator.id
      redirect_to new_access_point_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
    end
  end
end
