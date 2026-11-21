class AccessControlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :check ]

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
