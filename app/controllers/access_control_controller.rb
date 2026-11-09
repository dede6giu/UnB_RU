class AccessControlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:check]

  MEAL_COST = 4.50

  def check
    student = Student.find_by(registration: params[:registration])

    if student.nil?
      render json: { message: "Estudante Não Cadastrado" }, status: :not_found
    elsif student.balance >= MEAL_COST
      student.update!(balance: student.balance - MEAL_COST)
      render json: { message: "Acesso Liberado" }, status: :ok
    else
      render json: { message: "Saldo Insuficiente" }, status: :forbidden
    end
  end
end