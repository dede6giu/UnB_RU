# Controla especificamente a verificação de saldo para passagem de um
# estudante na catraca.
class AccessControlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :check ]

  ##
  # POST /access_control/check
  #
  # Recebe a matrícula de um estudante e tenta cobrar uma refeição.
  #
  # Caso a matrícula não esteja registrada, ou não há saldo suficiente,
  # o erro é reportado e nada acontece.
  #
  # Caso haja saldo suficiente na matrícula correspondente, retorna HTTP OK
  # e uma refeição é deduzida do saldo do estudante.
  def check
    student = Student.find_by(user: params[:registration]) || Student.find_by(user: params[:user])

    if student.nil?
      render json: { message: "Estudante Não Cadastrado" }, status: :not_found
    elsif student.pay_meal
      render json: { message: "Acesso Liberado" }, status: :ok
    else
      render json: { message: "Saldo Insuficiente" }, status: :forbidden
    end
  end
end
