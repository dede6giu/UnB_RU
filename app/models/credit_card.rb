class CreditCard
  include ActiveModel::Model

  attr_reader :number, :expiry
  attr_accessor :cvv

  # quem digita o número costuma copiar os espaços do cartão
  def number=(value)
    @number = value.to_s.delete(" ")
  end

  def expiry=(value)
    @expiry = value.to_s.strip
    @expiry = "#{@expiry[0, 2]}/#{@expiry[2, 2]}" if @expiry.match?(/\A\d{4}\z/)
  end

  validates :number, format: { with: /\A\d{16}\z/ }
  validates :cvv, format: { with: /\A\d{3}\z/ }
  validates :expiry, format: { with: %r{\A(0[1-9]|1[0-2])/\d{2}\z} }
  validate :expiry_not_in_the_past

  private

  # só roda com o formato já válido
  def expiry_not_in_the_past
    return if errors.include?(:expiry)

    month, year = expiry.split("/").map(&:to_i)
    last_valid_day = Date.new(2000 + year, month, 1).end_of_month
    errors.add(:expiry, "está vencida") if last_valid_day < Date.current
  end
end
