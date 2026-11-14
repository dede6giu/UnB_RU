module MessageTexts
  def message_kind(message_alias)
    case message_alias

    # Restaurant
    when /restaurant name is empty/
      'Nome não pode ser vazio'
    when /restaurant campus is empty/
      'Campus não pode ser vazio'
    when /existing restaurant/
      'Restaurante já existente'

    # Turnstile
    when /turnstiles in operation/
      'Há catracas em operação'
    when /turnstile in operation/
      'Um operador está atuando na catraca'
    when /turnstile name is empty/
      'Nome não pode ser vazio'
    when /existing turnstile/
      'Catraca já existente'

    when /incorrect credentials/
      'Matrícula ou senha incorretas.'
    when /invalid (admin|operator|student) id/
      'Matrícula inválida.'

    when /successful recharge/
      'Recarga realizada com sucesso.'
    when /invalid credit amount/
      'Quantidade inválida.'
    when /invalid Credit Card info/
      'Dados do cartão inválidos.'
    when /no transaction history/
      'Você ainda não tem lançamentos.'

    when /existing student/
      'Matrícula já registrada.'
    when /student name is empty/
      'Nome não pode ser vazio.'
    when /too short password/
      'Senha deve ter 8 ou mais caracteres.'

    else
      pending "Can't find mapping from \"#{message_alias}\" to a message.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(MessageTexts)
