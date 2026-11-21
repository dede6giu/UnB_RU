# Perfil de estudante de uma Account (mesma chave: a matrícula). Guarda o saldo da carteira, em
# centavos, e o bloqueio do FastPass; cada recarga ou refeição vira uma Transaction.
class Student < ApplicationRecord
  belongs_to :account, foreign_key: :user, inverse_of: :student
  has_many :transactions

  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }

  ##
  # Soma uma recarga ao saldo e registra o crédito no extrato.
  #
  # Recebe o valor em centavos e o meio de pagamento (`"pix"` ou `"credit_card"`). Retorna `true` quando
  # recarrega e `false` quando o valor ou o meio de pagamento são inválidos (nesse caso nada muda). No
  # sucesso, cria a Transaction de crédito e aumenta o saldo no banco; a soma é feita direto no banco, assim
  # duas recargas ao mesmo tempo não se perdem.
  def add_credit(amount_cents, payment_method)
    lancamento = Transaction.new(student: self, kind: "credit",
                                 amount_cents: amount_cents, payment_method: payment_method)
    return false unless lancamento.valid?

    transaction do
      lancamento.save!
      # soma direto no banco, assim duas recargas ao mesmo tempo não se perdem
      increment!(:balance_cents, amount_cents)
    end
    true
  end

  ##
  # Desconta um valor do saldo e registra o débito no extrato.
  #
  # Recebe o valor em centavos. Retorna `true` quando desconta e `false` quando o valor é inválido (nesse
  # caso nada muda). No sucesso, cria a Transaction de débito e diminui o saldo no banco. Não confere se há
  # saldo: para a entrada no restaurante, usar #pay_meal.
  def add_debit(amount_cents)
    lancamento = Transaction.new(student: self, kind: "debit",
                                 amount_cents: amount_cents)
    return false unless lancamento.valid?

    transaction do
      lancamento.save!
      decrement!(:balance_cents, amount_cents)
    end
    true
  end

  ##
  # Cobra uma refeição na entrada do restaurante.
  #
  # Não recebe argumentos. Retorna `true` quando cobra e `false` quando o saldo não dá para uma
  # refeição. Com saldo, cria um débito na tabela de lançamentos e diminui o saldo no banco; sem saldo,
  # não altera nada.
  def pay_meal
    return false if balance_cents < Recharge::MEAL_PRICE_CENTS

    add_debit(Recharge::MEAL_PRICE_CENTS)
  end
end
