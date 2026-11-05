class AccessPointsController < ApplicationController
  before_action :load_turnstiles, only: %i[new create]

  def new
  end

  def show
    @turnstile = Turnstile.find_by(operator_id: session[:operator_id])
    redirect_to new_access_point_path if @turnstile.nil?
  end

  def create
    operator = Account.find_by(id: session[:operator_id], role: "operator")
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

  def load_turnstiles
    @turnstiles = Turnstile.all
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
