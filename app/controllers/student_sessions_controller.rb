# Controller para a autenticação de Student. É responsável tanto pelo
# login quanto signup, transmitindo tais ações para o model correspondente.
class StudentSessionsController < ApplicationController
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
    student_params = params.require(:student).permit(:user, :password)
    if student_params[:user] !~ Account.user_format_for("student")
      flash.now[:alert] = "Matrícula inválida."
      render :new, status: :unprocessable_entity
      return
    end
    student = Account.find_by(user: student_params[:user], role: "student")
    if student && student.authenticate(student_params[:password])
      session[:student_id] = student.id

      redirect_to student_portal_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
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
    student = Account.new(user: params[:student_user],
                          name: params[:student_name],
                          role: "student",
                          password: params[:student_password],)
    if student.save
      session[:student_id] = student.id
      redirect_to student_portal_path, notice: "Sucesso no cadastro."
    else
      flash.now[:alert] = student.errors.messages
      render :signup, status: :unprocessable_entity
    end
  end
end
