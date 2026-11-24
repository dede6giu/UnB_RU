# Cartão de crédito usado na recarga (não tem tabela própria). Só confere o número (16 dígitos), o CVV
# (3 dígitos) e a validade (MM/AA, não vencida); nada do cartão é salvo.
class CreditCard
  include ActiveModel::Model

  # Número do cartão, já sem espaços.
  attr_reader :number
  # Validade no formato MM/AA e o código de segurança (CVV).
  attr_accessor :expiry, :cvv

  ##
  # Guarda o número do cartão tirando os espaços, porque quem digita costuma copiar o número com os
  # espaços do cartão.
  #
  # Recebe o número como veio do formulário (`value`). Não retorna valor útil; o efeito é guardar o
  # número limpo no objeto.
  def number=(value)
    @number = value.to_s.delete(" ")
  end

  validates :number, format: { with: /\A\d{16}\z/ }
  validates :cvv, format: { with: /\A\d{3}\z/ }
  validates :expiry, format: { with: %r{\A(0[1-9]|1[0-2])/\d{2}\z} }
  validate :expiry_not_in_the_past

  private

  ##
  # Validação da validade: o cartão vale até o último dia do mês de MM/AA. Só roda com o formato já
  # válido.
  #
  # Não recebe argumentos nem retorna valor útil. Se a validade já passou, adiciona o erro "está vencida".
  def expiry_not_in_the_past
    return if errors.include?(:expiry)

    month, year = expiry.split("/").map(&:to_i)
    last_valid_day = Date.new(2000 + year, month, 1).end_of_month
    errors.add(:expiry, "está vencida") if last_valid_day < Date.current
  end
end
