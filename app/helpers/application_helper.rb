module ApplicationHelper
  def reais(cents)
    number_to_currency(cents / 100.0, unit: "R$ ", separator: ",", delimiter: ".")
  end
end
