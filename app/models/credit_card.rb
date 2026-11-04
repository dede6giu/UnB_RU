class CreditCard
  include ActiveModel::Model

  attr_accessor :number, :expiry, :cvv

  validates :number, format: { with: /\A\d{16}\z/ }
  validates :cvv, format: { with: /\A\d{3}\z/ }
  validates :expiry, format: { with: %r{\A(0[1-9]|1[0-2])/\d{2}\z} }
  validate :expiry_not_in_the_past

  private

  # Só roda com o formato já válido; o cartão vale até o fim do mês impresso.
  def expiry_not_in_the_past
    return if errors.include?(:expiry)

    month, year = expiry.split("/").map(&:to_i)
    last_valid_day = Date.new(2000 + year, month, 1).end_of_month
    errors.add(:expiry, "está vencida") if last_valid_day < Date.current
  end
end
