class AccessControlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :check ]

  MEAL_COST_CENTS = Recharge::MEAL_PRICE_CENTS

  def check
    student = Student.find_by(user: params[:registration]) || Student.find_by(user: params[:user])

    if student.nil?
      render json: { message: "Estudante Não Cadastrado" }, status: :not_found
    elsif student.balance_cents >= MEAL_COST_CENTS
      student.add_debit(MEAL_COST_CENTS)
      render json: { message: "Acesso Liberado" }, status: :ok
    else
      render json: { message: "Saldo Insuficiente" }, status: :forbidden
    end
  end
end
