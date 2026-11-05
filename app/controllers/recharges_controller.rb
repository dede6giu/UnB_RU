class RechargesController < ApplicationController
  MEAL_PRICE_CENTS = 450
  PACKAGES = [ 2, 5, 10, 20 ]

  include StudentAuthentication

  def new
  end

  def create
    error = quantity_error || payment_error || credit_error

    if error
      flash.now[:alert] = error
      render :new, status: :unprocessable_entity
    else
      redirect_to statement_path, notice: "Recarga realizada com sucesso."
    end
  end

  private

  # sem "outra quantidade" preenchida o valor é o do pacote
  def chosen_quantity
    params.dig(:recharge, :quantity).presence || params.dig(:recharge, :package)
  end

  # sem o campo, o padrão é o pix
  def payment_method
    params.dig(:recharge, :payment_method).presence || "pix"
  end

  def payment_error
    if !Transaction::PAYMENT_METHODS.include?(payment_method)
      "Meio de pagamento inválido."
    elsif payment_method == "credit_card" && !card.valid?
      "Dados do cartão inválidos."
    end
  end

  def quantity
    Integer(chosen_quantity, exception: false)
  end

  # a quantidade é validada antes do pagamento, como na ordem do formulário
  def quantity_error
    "Quantidade inválida." unless quantity&.positive?
  end

  # só roda com quantidade e pagamento já validados, porque grava a recarga
  def credit_error
    "Quantidade inválida." unless @student.add_credit(quantity * MEAL_PRICE_CENTS, payment_method)
  end

  # o cartão só é validado, nunca gravado
  def card
    CreditCard.new(number: params.dig(:recharge, :card_number),
                   expiry: params.dig(:recharge, :card_expiry),
                   cvv: params.dig(:recharge, :card_cvv))
  end
end
