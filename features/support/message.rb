module MessageTexts
  def message_kind(message_alias)
    case message_alias

    # Restaurant
    when /nome do restaurante está vazio/
      'Nome não pode ser vazio'
    when /campus do restaurante está vazio/
      'Campus não pode ser vazio'
    when /restaurante existente/
      'Restaurante já existente'

    # Turnstile
    when /catracas em operação/
      'Há catracas em operação'
    when /catraca em operação/
      'Um operador está atuando na catraca'
    when /nome da catraca está vazio/
      'Nome não pode ser vazio'
    when /catraca existente/
      'Catraca já existente'

    # Shift configuration
    when /invalid shift/
      "Horário inválido. Verifique os horários e evite sobreposição entre turnos."

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

    when /access allowed/
      'Acesso liberado'
    when /not enough balance/
      'Saldo insuficiente'
    when /unregistered registration/
      'Matrícula não cadastrada'

    when /no global history/
      'Ainda não há histórico de acessos.'

    else
      pending "Can't find mapping from \"#{message_alias}\" to a message.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(MessageTexts)
