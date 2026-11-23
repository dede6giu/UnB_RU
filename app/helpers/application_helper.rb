# Helpers usados em todas as views (e no PDF do extrato).
module ApplicationHelper
  ##
  # Formata um valor em centavos como dinheiro brasileiro, por exemplo 1550 → "R$ 15,50".
  #
  # Recebe o valor em centavos (inteiro). Retorna o texto formatado; sem efeitos colaterais.
  def reais(cents)
    number_to_currency(cents / 100.0, unit: "R$ ", separator: ",", delimiter: ".")
  end
end
