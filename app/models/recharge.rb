# Recarga de saldo pedida pelo estudante (não tem tabela própria). Confere a quantidade de refeições,
# o meio de pagamento e, no cartão, os dados dele; se estiver tudo certo, vira um crédito no saldo.
class Recharge
  include ActiveModel::Model

  # Preço de uma refeição, em centavos (R$ 4,50).
  MEAL_PRICE_CENTS = 450
  # Pacotes de refeições oferecidos na tela.
  PACKAGES = [ 2, 5, 10, 20 ]
  # Maior quantidade de refeições numa recarga (R$ 450,00).
  MAX_MEALS = 100

  # Campos do formulário: o estudante que recarrega, o pacote ou a outra quantidade, o meio de
  # pagamento e os dados do cartão (que só são conferidos, nunca salvos).
  attr_accessor :student, :package, :quantity, :payment_method,
                :card_number, :card_expiry_month, :card_expiry_year, :card_cvv

  # A tela só mostra o primeiro erro, então a ordem aqui é a ordem do formulário.
  validates :meals, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_MEALS,
                                    message: "Quantidade inválida." }
  validates :payment_method, inclusion: { in: Transaction::PAYMENT_METHODS, message: "Meio de pagamento inválido." }
  validate :card_must_be_valid, if: -> { payment_method == "credit_card" }

  ##
  # Quantidade de refeições da recarga: a "outra quantidade", se foi preenchida, senão o pacote.
  #
  # Não recebe argumentos. Retorna o valor como veio do formulário (texto ou número, ou `nil`); sem
  # efeitos colaterais.
  def meals
    quantity.presence || package
  end

  ##
  # Valor da recarga em centavos: refeições × preço de uma refeição.
  #
  # Não recebe argumentos. Retorna um inteiro; sem efeitos colaterais.
  def amount_cents
    meals.to_i * MEAL_PRICE_CENTS
  end

  ##
  # Confere a recarga e, se estiver tudo certo, soma o valor ao saldo do estudante.
  #
  # Não recebe argumentos. Retorna `true` quando recarrega e `false` quando algum dado é inválido (os
  # erros ficam em `errors`). No sucesso, cria um crédito no extrato e aumenta o saldo no banco.
  def save
    valid? && student.add_credit(amount_cents, payment_method)
  end

  private

  ##
  # Validação do cartão (só roda com o meio de pagamento "credit_card").
  #
  # Não recebe argumentos nem retorna valor útil. Se o cartão for inválido, adiciona o erro "Dados do
  # cartão inválidos." Nada do cartão é salvo.
  def card_must_be_valid
    card = CreditCard.new(number: card_number, expiry: "#{card_expiry_month}/#{card_expiry_year}", cvv: card_cvv)
    errors.add(:base, "Dados do cartão inválidos.") unless card.valid?
  end
end
