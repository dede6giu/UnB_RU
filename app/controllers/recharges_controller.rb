class RechargesController < ApplicationController
  MEAL_PRICE_CENTS = 450
  PACKAGES = [ 2, 5, 10, 20 ]

  include StudentAuthentication

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
end
