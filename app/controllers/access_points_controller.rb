class AccessPointsController < ApplicationController
  layout "operator"
  helper_method :current_operator
  before_action :load_restaurants, only: %i[new create]

  def new
  end

  def show
    @turnstile = Turnstile.find_by(operator_id: session[:operator_id])
    redirect_to new_access_point_path if @turnstile.nil?
    @entry = flash[:entry]
    @student = Student.find_by(user: flash[:registration])
  end

  ##
  # POST /operator/access/validate
  #
  # Valida a matrícula digitada no Terminal de Validação (`params[:registration]`). Com saldo, libera e
  # cobra a refeição; sem saldo ou com matrícula não cadastrada, bloqueia.
  #
  # Não retorna valor: redireciona para o Terminal de Validação com o resultado e a matrícula no flash,
  # assim atualizar a página não cobra de novo. Quando libera, cria um débito e diminui o saldo do estudante.
  def validate
    student = Student.find_by(user: params[:registration])
    redirect_to access_point_path, flash: { entry: entry_result(student), registration: params[:registration] }
  end

  def create
    operator = Account.find_by(user: session[:operator_id], role: "operator")
    turnstile = Turnstile.find_by(id: params.dig(:access_point, :turnstile_id))
    if turnstile.nil?
      render_error("Escolha um ponto de acesso para iniciar a operação.")
    elsif turnstile.operation == "Inativa"
      render_error("O ponto de acesso escolhido está inativo.")
    elsif turnstile.operation == "Operando"
      render_error("O ponto de acesso escolhido já está em operação.")
    else
      current_turnstile = Turnstile.find_by(operator_id: operator.id)
      Turnstile.transaction do
        current_turnstile&.update!(operator_id: nil, operation: "Ativa")
        turnstile.update!(operator_id: operator.id, operation: "Operando")
      end
      redirect_to access_point_path, notice: "Operação iniciada com sucesso."
    end
  end

  def destroy
    turnstile = Turnstile.find_by(operator_id: session[:operator_id])
    if turnstile.nil?
      redirect_to new_access_point_path, alert: "Nenhum ponto de acesso em operação."
    else
      turnstile.update!(operator_id: nil, operation: "Ativa")
      redirect_to new_access_point_path, notice: "Operação encerrada com sucesso."
    end
  end

  def confirm_disconnect
  end

  private

  before_action :exigir_operador

  def load_restaurants
    @restaurants = Restaurant.includes(:turnstiles).order(:campus, :name)
  end

  def current_operator
    @current_operator ||= Account.find_by(user: session[:operator_id], role: "operator")
  end

  ##
  # Decide o resultado da validação para o estudante encontrado pela matrícula (`nil` se não existe).
  #
  # Retorna `"not_found"`, `"allowed"` ou `"no_balance"`. Quando retorna `"allowed"`, já cobrou a
  # refeição (ver Student#pay_meal).
  def entry_result(student)
    if student.nil?
      "not_found"
    elsif student.pay_meal
      "allowed"
    else
      "no_balance"
    end
  end

  def render_error(message)
    flash.now[:alert] = message
    render :new, status: :unprocessable_entity
  end

    def exigir_operador
    return if session[:operator_id].present?

    redirect_to new_operator_session_path, alert: "Faça login para continuar."
    end
end
