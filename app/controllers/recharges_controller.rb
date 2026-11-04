class RechargesController < ApplicationController
  MEAL_PRICE_CENTS = 450
  PACKAGES = [ 2, 5, 10, 20 ]

  before_action :require_student

  def new
  end

  private

  # A sessão guarda o id da Account; o saldo está no Student ligado a ela.
  def require_student
    @student = Student.find_by(account_id: session[:student_id])
    redirect_to new_student_session_path, alert: "Faça login para recarregar o saldo." unless @student
  end
end
