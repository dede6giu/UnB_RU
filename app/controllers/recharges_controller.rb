class RechargesController < ApplicationController
  MEAL_PRICE_CENTS = 450
  PACKAGES = [ 2, 5, 10, 20 ]

  before_action :require_student

  def new
  end

  def create
    quantity = Integer(chosen_quantity, exception: false)
    if quantity && @student.add_credit(quantity * MEAL_PRICE_CENTS, "pix")
      redirect_to student_portal_path, notice: "Recarga realizada com sucesso."
    else
      flash.now[:alert] = "Quantidade inválida."
      render :new, status: :unprocessable_entity
    end
  end

  private

  # sem "outra quantidade" preenchida o valor é o do pacote
  def chosen_quantity
    params.dig(:recharge, :quantity).presence || params.dig(:recharge, :package)
  end

  # A sessão guarda o id da Account; o saldo está no Student ligado a ela.
  def require_student
    @student = Student.find_by(account_id: session[:student_id])
    redirect_to new_student_session_path, alert: "Faça login para recarregar o saldo." unless @student
  end
end
