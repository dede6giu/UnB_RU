# Controller para a autenticação de Operator.
class OperatorSessionsController < ApplicationController
  include Authentication
  before_action :require_no_operator, only: %i[new create]

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
    account_values = operator_params
    if authenticate_operator(account_values)
      session[:operator_id] = account_values[:user]
      redirect_to new_access_point_path, notice: "Sucesso na autenticação."
    else
      failed_login(account_values)
    end
  end

  ##
  # DELETE /operator/login
  #
  # Encerra a sessão do operador. Não recebe argumentos.
  #
  # Se o operador ainda estiver conectado a uma catraca, ela é liberada
  # (fica sem operador e volta para "Ativa") antes de sair, para não ficar presa
  # a uma sessão que não existe mais. Remove o registro da sessão e redireciona
  # para OperatorSessionsController#new com "Você saiu da conta.".
  def destroy
    Turnstile.find_by(operator_id: session[:operator_id])&.update!(operator_id: nil, operation: "Ativa")
    session.delete(:operator_id)
    redirect_to new_operator_session_path, notice: "Você saiu da conta."
  end

  private

  def operator_params
    params.require(:operator).permit(:user, :password)
  end

  def valid_userid(userid)
    userid =~ Account.user_format_for("operator")
  end

  def authenticate_operator(account_values)
    operator = Account.find_by(user: account_values[:user], role: "operator")
    if operator
      operator.authenticate(account_values[:password])
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
