# Controller para a autenticação de Student. É responsável tanto pelo
# login quanto signup, transmitindo tais ações para o model correspondente.
class StudentSessionsController < ApplicationController
  include Authentication
  before_action :require_no_student, only: %i[new create signup newacc]

  ##
  # GET /student/login
  #
  # Chamado durante o processo, mas não realiza nada.
  def new
  end

  ##
  # POST /student/login
  #
  # Verifica as credenciais passadas como parâmetro do formulário,
  # e então compara-as com a database.
  #
  # Caso exista algum Student com as mesmas credenciais, cria-se uma nova sessão.
  # O estudante é redirecionado para StudentPortalController#show.
  #
  # Caso as credenciais não sejam válidas, avisa que os valores não foram
  # escritos corretamente. O usuário retorna para StudentSessionsController#new.
  #
  # Caso as credenciais são válidas mas não tem correspondência, avisa que
  # algo está errado, mas não *o quê* (questões de segurança).
  # O usuário retorna para StudentSessionsController#new.
  def create
    account_values = student_params
    if authenticate_student(account_values)
      session[:student_id] = account_values[:user]
      redirect_to student_portal_path, notice: "Sucesso na autenticação."
    else
      failed_login(account_values)
    end
  end

  ##
  # GET /student/signup
  #
  # Chamado durante o processo, mas não realiza nada.
  def signup
  end

  ##
  # POST /student/login
  #
  # Verifica as informações passadas pelo formulário e tenta
  # registrar um novo Student.
  #
  # Em sucesso, o Student é salvo na database, e já é adicionado como
  # a sessão atual. O usuário é redirecionado para StudentPortalController#show.
  #
  # Em falha, o Student não é salvo na database. Os erros são mostrados.
  # O usuário retorna para StudentSessionsController#new.
  def newacc
    result, student = create_new_student(params)
    if result
      session[:student_id] = student.id
      redirect_to student_portal_path, notice: "Sucesso no cadastro."
    else
      flash.now[:alert] = student.errors.map { |erro| erro.message }
      render :signup, status: :unprocessable_entity
    end
  end

  ##
  # DELETE /student/login
  #
  # Encerra a sessão do estudante. Não recebe argumentos.
  #
  # Remove o registro da sessão e redireciona para
  # StudentSessionsController#new com "Você saiu da conta.".
  def destroy
    session.delete(:student_id)
    redirect_to new_student_session_path, notice: "Você saiu da conta."
  end

  private

  def create_new_student(params)
    student = Account.new(user: params[:student_user], name: params[:student_name], role: "student", password: params[:student_password])
    [ student.save, student ]
  end

  def student_params
    params.require(:student).permit(:user, :password)
  end

  def valid_userid(userid)
    userid =~ Account.user_format_for("student")
  end

  def authenticate_student(account_values)
    student = Account.find_by(user: account_values[:user], role: "student")
    if student
      student.authenticate(account_values[:password])
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
