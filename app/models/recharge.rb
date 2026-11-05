class Recharge
  include ActiveModel::Model

  MEAL_PRICE_CENTS = 450
  PACKAGES = [ 2, 5, 10, 20 ]
  MAX_MEALS = 100

  attr_accessor :student, :package, :quantity, :payment_method, :card_number, :card_expiry, :card_cvv

  # A tela só mostra o primeiro erro, então a ordem aqui é a ordem do formulário.
  validates :meals, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_MEALS,
                                    message: "Quantidade inválida." }
  validates :payment_method, inclusion: { in: Transaction::PAYMENT_METHODS, message: "Meio de pagamento inválido." }
  validate :card_must_be_valid, if: -> { payment_method == "credit_card" }

  # "Outra quantidade" vale mais que o pacote.
  def meals
    quantity.presence || package
  end

  def amount_cents
    meals.to_i * MEAL_PRICE_CENTS
  end

  def save
    valid? && student.add_credit(amount_cents, payment_method)
  end

  private

  # O cartão só é conferido; nada dele é salvo.
  def card_must_be_valid
    card = CreditCard.new(number: card_number, expiry: card_expiry, cvv: card_cvv)
    errors.add(:base, "Dados do cartão inválidos.") unless card.valid?
  end
end
